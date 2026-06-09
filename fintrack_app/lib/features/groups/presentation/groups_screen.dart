import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../data/group_repository.dart';
import '../../../shared/models/group_model.dart';
import '../../../shared/models/user_model.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../core/constants/app_theme.dart';

class GroupsScreen extends ConsumerStatefulWidget {
  const GroupsScreen({super.key});

  @override
  ConsumerState<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends ConsumerState<GroupsScreen> {
  List<GroupModel> _groups = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final groups = await ref.read(groupRepositoryProvider).listGroups();
      setState(() { _groups = groups; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final currentUserId = user?.id ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Mis grupos')),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _groups.isEmpty
                ? _buildEmpty(context)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _groups.length,
                    itemBuilder: (_, i) => _GroupCard(
                      group: _groups[i],
                      currentUserId: currentUserId,
                      onTap: () => context.go('/dashboard?groupId=${_groups[i].id}'),
                      onInvite: () => _showInviteDialog(_groups[i]),
                      onLeave: () => _confirmLeaveGroup(_groups[i]),
                      onManageMembers: () => _showMembersDialog(_groups[i], currentUserId),
                      onDelete: () => _confirmDeleteGroup(_groups[i]),
                    ).animate().fadeIn(delay: (i * 80).ms).slideY(begin: 0.2),
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Nuevo grupo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ).animate().scale(delay: 400.ms),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('💰', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text('Aún no tenés grupos', style: TextStyle(
            color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold,
          )),
          const SizedBox(height: 8),
          const Text(
            'Creá un grupo para compartir\ntus finanzas con otros',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _showCreateDialog,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Crear primer grupo'),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _showJoinDialog,
            icon: const Icon(Icons.group_add_rounded, color: AppColors.accent),
            label: const Text('Unirme con código', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String selectedEmoji = '💰';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nuevo grupo', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            // Emoji picker
            StatefulBuilder(builder: (_, setLocal) {
              return Row(
                children: ['💰', '🏠', '✈️', '🏢', '🎉', '🛒', '💊', '🎓'].map((e) =>
                  GestureDetector(
                    onTap: () { setLocal(() => selectedEmoji = e); },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: selectedEmoji == e ? AppColors.primary.withOpacity(0.2) : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: selectedEmoji == e ? AppColors.primary : Colors.transparent),
                      ),
                      child: Text(e, style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                ).toList(),
              );
            }),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Nombre del grupo'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Descripción (opcional)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                try {
                  final group = await ref.read(groupRepositoryProvider).createGroup(
                    name: nameCtrl.text.trim(),
                    description: descCtrl.text.trim().isNotEmpty ? descCtrl.text.trim() : null,
                    emoji: selectedEmoji,
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                  _load();

                  if (group.inviteCode != null && mounted) {
                    _showInviteSuccessDialog(group);
                  }
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                      content: Text('Error al crear: $e'),
                      backgroundColor: AppColors.expense,
                    ));
                  }
                }
              },
              child: const Text('Crear grupo'),
            ),
          ],
        ),
      ),
    );
  }

  void _showInviteSuccessDialog(GroupModel group) {
    final code = group.inviteCode!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            Text(group.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            const Text('¡Grupo Creado! 🎉'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Tu grupo ha sido creado. Compartí este código de invitación con otros miembros para que se unan:',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Text(
              code,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                letterSpacing: 8,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Este código expira en 7 días.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Código copiado'), behavior: SnackBarBehavior.floating),
              );
            },
            child: const Text('Copiar código', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Entendido', style: TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  void _showJoinDialog() {
    final codeCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Unirme a un grupo', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Ingresá el código de invitación de 8 caracteres', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 20),
            TextField(
              controller: codeCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              maxLength: 8,
              style: const TextStyle(letterSpacing: 6, fontSize: 22, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(labelText: 'Código de invitación', counterText: ''),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (codeCtrl.text.trim().length != 8) return;
                try {
                  await ref.read(groupRepositoryProvider).joinByCode(codeCtrl.text.trim());
                  if (ctx.mounted) Navigator.pop(ctx);
                  _load();
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                      content: Text(e.toString().replaceAll('Exception: ', '')),
                      backgroundColor: AppColors.expense,
                    ));
                  }
                }
              },
              child: const Text('Unirme'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showInviteDialog(GroupModel group) async {
    try {
      final inviteData = await ref.read(groupRepositoryProvider).createInvitation(group.id);
      final code = inviteData['code'] as String;

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text('Código de invitación'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  code,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    letterSpacing: 8,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Compartí este código. Expira en 7 días.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: code));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Código copiado'), behavior: SnackBarBehavior.floating),
                  );
                },
                child: const Text('Copiar código', style: TextStyle(color: AppColors.primary)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Entendido', style: TextStyle(color: AppColors.textSecondary)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: AppColors.expense),
        );
      }
    }
  }

  void _showMembersDialog(GroupModel group, int currentUserId) {
    final isOwner = group.ownerId == currentUserId;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Miembros: ${group.name}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${group.members.length} miembros',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: group.members.length,
                    itemBuilder: (context, index) {
                      final member = group.members[index];
                      final isMemberOwner = member.id == group.ownerId;
                      final isMe = member.id == currentUserId;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppColors.primary.withOpacity(0.2),
                                  child: Text(
                                    member.name[0].toUpperCase(),
                                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isMe ? '${member.name} (Vos)' : member.name,
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                    ),
                                    Text(
                                      member.email,
                                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (isMemberOwner)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Propietario',
                                  style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              )
                            else if (isOwner && !isMe)
                              IconButton(
                                icon: const Icon(Icons.person_remove_outlined, color: AppColors.expense, size: 20),
                                onPressed: () => _confirmRemoveMember(group, member),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  void _confirmRemoveMember(GroupModel group, UserModel member) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Eliminar miembro'),
        content: Text('¿Estás seguro de que querés eliminar a ${member.name} de este grupo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Close bottom sheet
              setState(() => _loading = true);
              try {
                await ref.read(groupRepositoryProvider).removeMember(group.id, member.id);
                _load();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${member.name} ha sido eliminado del grupo.'), behavior: SnackBarBehavior.floating),
                  );
                }
              } catch (e) {
                setState(() => _loading = false);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al eliminar: $e'), backgroundColor: AppColors.expense),
                  );
                }
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: AppColors.expense, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmLeaveGroup(GroupModel group) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Abandonar grupo'),
        content: Text('¿Estás seguro de que querés salir del grupo "${group.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _loading = true);
              try {
                await ref.read(groupRepositoryProvider).leaveGroup(group.id);
                _load();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Saliste de "${group.name}" correctamente.'), behavior: SnackBarBehavior.floating),
                  );
                }
              } catch (e) {
                setState(() => _loading = false);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al salir: $e'), backgroundColor: AppColors.expense),
                  );
                }
              }
            },
            child: const Text('Salir', style: TextStyle(color: AppColors.expense, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteGroup(GroupModel group) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Eliminar grupo'),
        content: Text('¿Estás seguro de que deseas eliminar el grupo "${group.name}"? Esta acción no se puede deshacer y borrará todos los movimientos relacionados.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _loading = true);
              try {
                await ref.read(groupRepositoryProvider).deleteGroup(group.id);
                _load();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Grupo "${group.name}" eliminado correctamente.'), behavior: SnackBarBehavior.floating),
                  );
                }
              } catch (e) {
                setState(() => _loading = false);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al eliminar: $e'), backgroundColor: AppColors.expense),
                  );
                }
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: AppColors.expense, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final GroupModel group;
  final int currentUserId;
  final VoidCallback onTap;
  final VoidCallback onInvite;
  final VoidCallback onLeave;
  final VoidCallback onManageMembers;
  final VoidCallback onDelete;

  const _GroupCard({
    required this.group,
    required this.currentUserId,
    required this.onTap,
    required this.onInvite,
    required this.onLeave,
    required this.onManageMembers,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isOwner = group.ownerId == currentUserId;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(child: Text(group.emoji, style: const TextStyle(fontSize: 26))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(group.name, style: const TextStyle(
                    color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16,
                  )),
                  if (group.description != null) ...[
                    const SizedBox(height: 2),
                    Text(group.description!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                  const SizedBox(height: 6),
                  Row(children: [
                    const Icon(Icons.people_outline, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text('${group.members.length} miembros', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    if (group.transactionsCount != null) ...[
                      const Text(' · ', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      Text('${group.transactionsCount} movimientos', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ]),
                ],
              ),
            ),
            PopupMenuButton<String>(
              color: AppColors.surface,
              icon: const Icon(Icons.more_vert, color: AppColors.textMuted),
              onSelected: (v) {
                if (v == 'invite') onInvite();
                if (v == 'leave') onLeave();
                if (v == 'members') onManageMembers();
                if (v == 'delete') onDelete();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'invite',
                  child: Row(
                    children: [
                      Icon(Icons.person_add_outlined, size: 18, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text('Invitar miembro'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'members',
                  child: Row(
                    children: [
                      Icon(Icons.people_outline, size: 18, color: AppColors.textSecondary),
                      SizedBox(width: 8),
                      Text('Ver miembros'),
                    ],
                  ),
                ),
                if (!isOwner)
                  const PopupMenuItem(
                    value: 'leave',
                    child: Row(
                      children: [
                        Icon(Icons.logout_rounded, size: 18, color: AppColors.expense),
                        SizedBox(width: 8),
                        Text('Abandonar grupo', style: TextStyle(color: AppColors.expense)),
                      ],
                    ),
                  ),
                if (isOwner)
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.expense),
                        SizedBox(width: 8),
                        Text('Eliminar grupo', style: TextStyle(color: AppColors.expense)),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
