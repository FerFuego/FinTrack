<!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FinTrack — Control Colectivo de Gastos</title>
    <link
        href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&family=Plus+Jakarta+Sans:wght@300;400;500;600;700&display=swap"
        rel="stylesheet">
    <style>
        :root {
            --background: #060913;
            --surface: #0F1322;
            --surface-hover: #171C30;
            --primary: #635BFF;
            --primary-glow: rgba(99, 91, 255, 0.45);
            --secondary: #9C27B0;
            --secondary-glow: rgba(156, 39, 176, 0.45);
            --accent: #00F2FE;
            --accent-glow: rgba(0, 242, 254, 0.3);
            --text-primary: #FFFFFF;
            --text-secondary: #94A3B8;
            --text-muted: #64748B;
            --border: rgba(255, 255, 255, 0.08);
            --border-hover: rgba(255, 255, 255, 0.15);
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: 'Plus Jakarta Sans', sans-serif;
            background-color: var(--background);
            color: var(--text-primary);
            overflow-x: hidden;
            line-height: 1.6;
        }

        /* Glowing aurora background effects */
        .aurora-bg {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 900px;
            z-index: -1;
            overflow: hidden;
            pointer-events: none;
        }

        .aurora-glow-1 {
            position: absolute;
            top: -200px;
            left: -100px;
            width: 600px;
            height: 600px;
            border-radius: 50%;
            background: radial-gradient(circle, var(--primary-glow) 0%, rgba(6, 9, 19, 0) 70%);
            filter: blur(80px);
            animation: float-slow 15s infinite alternate;
        }

        .aurora-glow-2 {
            position: absolute;
            top: 100px;
            right: -200px;
            width: 700px;
            height: 700px;
            border-radius: 50%;
            background: radial-gradient(circle, var(--secondary-glow) 0%, rgba(6, 9, 19, 0) 70%);
            filter: blur(100px);
            animation: float-slow 20s infinite alternate-reverse;
        }

        .aurora-glow-3 {
            position: absolute;
            top: 500px;
            left: 30%;
            width: 500px;
            height: 500px;
            border-radius: 50%;
            background: radial-gradient(circle, var(--accent-glow) 0%, rgba(6, 9, 19, 0) 70%);
            filter: blur(90px);
        }

        @keyframes float-slow {
            0% {
                transform: translate(0, 0) scale(1);
            }

            100% {
                transform: translate(50px, 40px) scale(1.1);
            }
        }

        /* Header Navigation */
        header {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            z-index: 100;
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            border-bottom: 1px solid var(--border);
            background: rgba(6, 9, 19, 0.7);
            transition: all 0.3s ease;
        }

        .nav-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 18px 24px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .logo-group {
            display: flex;
            align-items: center;
            gap: 10px;
            text-decoration: none;
        }

        .logo-icon {
            width: 38px;
            height: 38px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Outfit', sans-serif;
            font-weight: 800;
            color: #FFFFFF;
            font-size: 20px;
            box-shadow: 0 4px 15px rgba(99, 91, 255, 0.4);
        }

        .logo-text {
            font-family: 'Outfit', sans-serif;
            font-size: 24px;
            font-weight: 800;
            letter-spacing: -0.5px;
            background: linear-gradient(135deg, #FFFFFF 0%, #E2E8F0 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .nav-links {
            display: flex;
            gap: 24px;
            align-items: center;
        }

        .nav-link {
            color: var(--text-secondary);
            text-decoration: none;
            font-size: 14px;
            font-weight: 500;
            transition: color 0.2s;
        }

        .nav-link:hover {
            color: #FFFFFF;
        }

        /* Hero Section */
        .hero {
            padding: 160px 24px 80px;
            max-width: 1200px;
            margin: 0 auto;
            display: grid;
            grid-template-columns: 1.2fr 0.8fr;
            gap: 60px;
            align-items: center;
        }

        .hero-info {
            display: flex;
            flex-direction: column;
            gap: 24px;
        }

        .badge {
            align-self: flex-start;
            background: rgba(99, 91, 255, 0.1);
            border: 1px solid rgba(99, 91, 255, 0.25);
            color: #A5B4FC;
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            letter-spacing: 0.5px;
            text-transform: uppercase;
        }

        .hero-title {
            font-family: 'Outfit', sans-serif;
            font-size: 56px;
            font-weight: 800;
            line-height: 1.15;
            letter-spacing: -1.5px;
            background: linear-gradient(135deg, #FFFFFF 30%, #94A3B8 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .hero-title span {
            background: linear-gradient(135deg, var(--primary) 0%, var(--accent) 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            text-shadow: 0 0 40px rgba(99, 91, 255, 0.2);
        }

        .hero-description {
            font-size: 18px;
            color: var(--text-secondary);
            max-width: 580px;
            font-weight: 400;
        }

        /* Direct Download Container */
        .download-container {
            background: rgba(15, 19, 34, 0.6);
            border: 1px solid var(--border);
            border-radius: 20px;
            padding: 24px;
            margin-top: 15px;
            backdrop-filter: blur(10px);
            display: flex;
            flex-direction: column;
            gap: 16px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.25);
        }

        .download-header-text {
            font-size: 14px;
            font-weight: 600;
            color: #FFFFFF;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .download-header-text svg {
            fill: var(--accent);
        }

        .download-buttons {
            display: flex;
            flex-wrap: wrap;
            gap: 14px;
        }

        .btn-download {
            flex: 1;
            min-width: 200px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 12px;
            background-color: var(--surface);
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 14px 20px;
            color: #FFFFFF;
            font-weight: 600;
            font-size: 14px;
            text-decoration: none;
            transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
            cursor: pointer;
        }

        .btn-download.android:hover {
            background-color: rgba(164, 198, 57, 0.1);
            border-color: #A4C639;
            box-shadow: 0 0 20px rgba(164, 198, 57, 0.25);
            transform: translateY(-2px);
        }

        .btn-download.ios:hover {
            background-color: rgba(255, 255, 255, 0.05);
            border-color: #FFFFFF;
            box-shadow: 0 0 20px rgba(255, 255, 255, 0.15);
            transform: translateY(-2px);
        }

        .btn-download svg {
            width: 22px;
            height: 22px;
            fill: currentColor;
            transition: transform 0.2s ease;
        }

        .btn-download:hover svg {
            transform: scale(1.1);
        }

        .download-notice {
            font-size: 11px;
            color: var(--text-muted);
            display: flex;
            gap: 6px;
            align-items: flex-start;
        }

        /* Mockup Mobile Phone container */
        .phone-mockup-container {
            display: flex;
            justify-content: center;
            align-items: center;
            position: relative;
        }

        .phone-glow {
            position: absolute;
            width: 320px;
            height: 600px;
            background: linear-gradient(135deg, var(--primary) 0%, var(--secondary) 100%);
            filter: blur(50px);
            opacity: 0.35;
            z-index: 0;
            border-radius: 40px;
        }

        .phone-frame {
            position: relative;
            z-index: 1;
            width: 290px;
            height: 590px;
            background-color: #000000;
            border: 11px solid #1E293B;
            border-radius: 42px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.7);
            overflow: hidden;
            display: flex;
            flex-direction: column;
        }

        /* Speaker & Camera Notch */
        .phone-notch {
            position: absolute;
            top: 0;
            left: 50%;
            transform: translateX(-50%);
            width: 110px;
            height: 22px;
            background-color: #1E293B;
            border-bottom-left-radius: 14px;
            border-bottom-right-radius: 14px;
            z-index: 10;
        }

        /* Simulated App Screen */
        .app-screen {
            flex: 1;
            background-color: #0A0E1A;
            padding: 30px 16px 16px;
            display: flex;
            flex-direction: column;
            gap: 16px;
            font-family: 'Plus Jakarta Sans', sans-serif;
        }

        .app-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 10px;
        }

        .app-profile {
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .app-avatar {
            width: 32px;
            height: 32px;
            background-color: var(--primary);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 12px;
            color: #FFFFFF;
        }

        .app-user-info h4 {
            font-size: 12px;
            font-weight: 600;
            color: #FFFFFF;
        }

        .app-user-info p {
            font-size: 10px;
            color: var(--text-muted);
        }

        .app-badge-group {
            background-color: rgba(255, 255, 255, 0.05);
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 10px;
            color: var(--accent);
            font-weight: 600;
            border: 1px solid rgba(0, 242, 254, 0.15);
        }

        .app-card {
            background: linear-gradient(135deg, #141928 0%, #101422 100%);
            border: 1px solid rgba(255, 255, 255, 0.05);
            border-radius: 18px;
            padding: 16px;
            display: flex;
            flex-direction: column;
            gap: 12px;
            position: relative;
            overflow: hidden;
        }

        .app-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 4px;
            background: linear-gradient(90deg, var(--primary) 0%, var(--secondary) 100%);
        }

        .app-card h5 {
            font-size: 11px;
            color: var(--text-secondary);
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .app-balance {
            font-family: 'Outfit', sans-serif;
            font-size: 26px;
            font-weight: 700;
            color: #FFFFFF;
        }

        .app-summary {
            display: flex;
            justify-content: space-between;
            gap: 8px;
            margin-top: 4px;
        }

        .app-summary-item {
            flex: 1;
            background: rgba(255, 255, 255, 0.02);
            border: 1px solid rgba(255, 255, 255, 0.04);
            border-radius: 10px;
            padding: 8px;
            display: flex;
            flex-direction: column;
            gap: 2px;
        }

        .app-summary-item.in {
            border-left: 2px solid #10B981;
        }

        .app-summary-item.out {
            border-left: 2px solid #EF4444;
        }

        .app-summary-label {
            font-size: 8px;
            color: var(--text-muted);
        }

        .app-summary-val {
            font-size: 11px;
            font-weight: 700;
        }

        .app-summary-item.in .app-summary-val {
            color: #10B981;
        }

        .app-summary-item.out .app-summary-val {
            color: #EF4444;
        }

        .app-list-title {
            font-size: 12px;
            font-weight: 600;
            color: #FFFFFF;
            margin-bottom: -4px;
        }

        .app-tx-list {
            display: flex;
            flex-direction: column;
            gap: 8px;
            flex: 1;
            overflow: hidden;
        }

        .app-tx-item {
            background-color: rgba(255, 255, 255, 0.02);
            border: 1px solid rgba(255, 255, 255, 0.04);
            border-radius: 12px;
            padding: 10px 12px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            animation: list-slide 4s infinite alternate;
        }

        @keyframes list-slide {
            0% {
                transform: translateY(0);
            }

            100% {
                transform: translateY(-5px);
            }
        }

        .app-tx-left {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .app-tx-icon-bg {
            width: 28px;
            height: 28px;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
        }

        .app-tx-icon-bg.in {
            background-color: rgba(16, 185, 129, 0.1);
            color: #10B981;
        }

        .app-tx-icon-bg.out {
            background-color: rgba(239, 68, 68, 0.1);
            color: #EF4444;
        }

        .app-tx-details h6 {
            font-size: 11px;
            font-weight: 600;
            color: #FFFFFF;
        }

        .app-tx-details p {
            font-size: 9px;
            color: var(--text-muted);
        }

        .app-tx-right {
            text-align: right;
        }

        .app-tx-amount {
            font-size: 11px;
            font-weight: 700;
        }

        .app-tx-amount.in {
            color: #10B981;
        }

        .app-tx-amount.out {
            color: #EF4444;
        }

        .app-tx-user {
            font-size: 8px;
            color: var(--text-muted);
        }

        /* Features Section */
        .features-section {
            padding: 80px 24px;
            max-width: 1200px;
            margin: 0 auto;
            position: relative;
        }

        .section-header {
            text-align: center;
            margin-bottom: 60px;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 12px;
        }

        .section-title {
            font-family: 'Outfit', sans-serif;
            font-size: 38px;
            font-weight: 800;
            background: linear-gradient(135deg, #FFFFFF 60%, #94A3B8 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .section-desc {
            color: var(--text-secondary);
            max-width: 600px;
            font-size: 16px;
        }

        .features-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
            gap: 24px;
        }

        .feature-card {
            background-color: var(--surface);
            border: 1px solid var(--border);
            border-radius: 24px;
            padding: 32px;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            display: flex;
            flex-direction: column;
            gap: 16px;
            position: relative;
            overflow: hidden;
        }

        .feature-card:hover {
            border-color: var(--border-hover);
            transform: translateY(-5px);
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.35);
        }

        .feature-card::after {
            content: '';
            position: absolute;
            top: 0;
            right: 0;
            width: 120px;
            height: 120px;
            background: radial-gradient(circle, var(--primary-glow) 0%, rgba(6, 9, 19, 0) 70%);
            opacity: 0;
            transition: opacity 0.3s;
            pointer-events: none;
            filter: blur(20px);
        }

        .feature-card:hover::after {
            opacity: 0.6;
        }

        .feature-icon-wrapper {
            width: 48px;
            height: 48px;
            background-color: rgba(99, 91, 255, 0.1);
            border: 1px solid rgba(99, 91, 255, 0.2);
            border-radius: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--primary);
        }

        .feature-card:hover .feature-icon-wrapper {
            background-color: var(--primary);
            color: #FFFFFF;
            box-shadow: 0 4px 15px var(--primary-glow);
            transform: rotate(5deg);
            transition: all 0.2s ease;
        }

        .feature-card h3 {
            font-size: 20px;
            font-weight: 700;
            color: #FFFFFF;
        }

        .feature-card p {
            color: var(--text-secondary);
            font-size: 14px;
            line-height: 1.6;
        }

        /* Direct Installation Instructions Modal/Section */
        .installation-guide {
            padding: 80px 24px;
            max-width: 1200px;
            margin: 0 auto;
            border-top: 1px solid var(--border);
        }

        .guide-container {
            background: linear-gradient(135deg, rgba(15, 19, 34, 0.8) 0%, rgba(9, 12, 23, 0.8) 100%);
            border: 1px solid var(--border);
            border-radius: 30px;
            padding: 48px;
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 48px;
            backdrop-filter: blur(10px);
            align-items: center;
        }

        .guide-info {
            display: flex;
            flex-direction: column;
            gap: 20px;
        }

        .guide-title {
            font-family: 'Outfit', sans-serif;
            font-size: 32px;
            font-weight: 800;
            color: #FFFFFF;
        }

        .guide-steps {
            display: flex;
            flex-direction: column;
            gap: 16px;
        }

        .step-item {
            display: flex;
            gap: 16px;
            align-items: flex-start;
        }

        .step-number {
            width: 28px;
            height: 28px;
            border-radius: 50%;
            background-color: rgba(0, 242, 254, 0.1);
            border: 1px solid var(--accent);
            color: var(--accent);
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 13px;
            flex-shrink: 0;
        }

        .step-text h4 {
            font-size: 14px;
            font-weight: 700;
            color: #FFFFFF;
            margin-bottom: 2px;
        }

        .step-text p {
            font-size: 13px;
            color: var(--text-secondary);
        }

        .qr-wrapper {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            gap: 15px;
            background: rgba(6, 9, 19, 0.6);
            border: 1px solid var(--border);
            padding: 30px;
            border-radius: 20px;
            text-align: center;
        }

        .qr-placeholder {
            width: 160px;
            height: 160px;
            background-color: #FFFFFF;
            border-radius: 12px;
            padding: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.3);
        }

        /* Footer */
        footer {
            border-top: 1px solid var(--border);
            background-color: rgba(6, 9, 19, 0.95);
            padding: 40px 24px;
            text-align: center;
            position: relative;
        }

        .footer-container {
            max-width: 1200px;
            margin: 0 auto;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 20px;
        }

        .footer-links {
            display: flex;
            gap: 30px;
        }

        .footer-link {
            color: var(--text-muted);
            text-decoration: none;
            font-size: 13px;
            transition: color 0.2s;
        }

        .footer-link:hover {
            color: #FFFFFF;
        }

        .copyright {
            font-size: 12px;
            color: var(--text-muted);
        }

        /* iOS Alert Tooltip/Message styling */
        .ios-tooltip-box {
            display: none;
            background: rgba(15, 19, 34, 0.95);
            border: 1px solid #9C27B0;
            border-radius: 14px;
            padding: 16px;
            font-size: 12px;
            color: var(--text-secondary);
            margin-top: 10px;
            animation: fadeIn 0.3s ease;
        }

        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(-5px);
            }

            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* Responsive Breakpoints */
        @media (max-width: 968px) {
            .hero {
                grid-template-columns: 1fr;
                gap: 50px;
                text-align: center;
                padding-top: 130px;
            }

            .badge {
                align-self: center;
            }

            .hero-title {
                font-size: 42px;
            }

            .hero-description {
                margin: 0 auto;
            }

            .download-container {
                max-width: 600px;
                margin: 15px auto 0;
                text-align: left;
            }

            .guide-container {
                grid-template-columns: 1fr;
                gap: 30px;
                padding: 30px;
            }
        }
    </style>
</head>

<body>

    <!-- Aurora shapes -->
    <div class="aurora-bg">
        <div class="aurora-glow-1"></div>
        <div class="aurora-glow-2"></div>
        <div class="aurora-glow-3"></div>
    </div>

    <!-- Header Navigation -->
    <header>
        <div class="nav-container">
            <a href="#" class="logo-group">
                <div class="logo-icon">
                    <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"
                        viewBox="0 0 64 64" style="width: 26px; height: 26px;">
                        <g transform="matrix(.061615 0 0 .061615 -1.430818 -1.2754)">
                            <defs>
                                <path id="A"
                                    d="M959.4 500L679.8 779.7l279.6 279.7H639.9L360.2 779.7 639.9 500h319.5zM639.9 20.7L120.6 540l159.8 159.8 679-679.1H639.9z" />
                            </defs>
                            <clipPath id="B">
                                <use xlink:href="#A" />
                            </clipPath>
                            <g clip-path="url(#B)">
                                <path d="M360.3 779.7L520 939.5 959.4 500H639.9z" fill="#39cefd" />
                            </g>
                            <defs>
                                <path id="C"
                                    d="M959.4 500L679.8 779.7l279.6 279.7H639.9L360.2 779.7 639.9 500h319.5zM639.9 20.7L120.6 540l159.8 159.8 679-679.1H639.9z" />
                            </defs>
                            <clipPath id="D">
                                <use xlink:href="#C" />
                            </clipPath>
                            <path clip-path="url(#D)" d="M639.9 20.7h319.5l-679 679.1L120.6 540z" fill="#39cefd" />
                            <defs>
                                <path id="E"
                                    d="M959.4 500L679.8 779.7l279.6 279.7H639.9L360.2 779.7 639.9 500h319.5zM639.9 20.7L120.6 540l159.8 159.8 679-679.1H639.9z" />
                            </defs>
                            <clipPath id="F">
                                <use xlink:href="#E" />
                            </clipPath>
                            <path clip-path="url(#F)" d="M520 939.5l119.9 119.8h319.5L679.8 779.7z" fill="#03569b" />
                            <defs>
                                <path id="G"
                                    d="M959.4 500L679.8 779.7l279.6 279.7H639.9L360.2 779.7 639.9 500h319.5zM639.9 20.7L120.6 540l159.8 159.8 679-679.1H639.9z" />
                            </defs>
                            <clipPath id="H">
                                <use xlink:href="#G" />
                            </clipPath>
                            <linearGradient id="I" gradientUnits="userSpaceOnUse" x1="566.635" y1="970.339" x2="685.65"
                                y2="851.324">
                                <stop offset="0" stop-color="#1a237e" stop-opacity=".4" />
                                <stop offset="1" stop-color="#1a237e" stop-opacity="0" />
                            </linearGradient>
                            <path clip-path="url(#H)" d="M757 857.4l-77.2-77.7L520 939.5z" fill="url(#I)" />
                            <defs>
                                <path id="J"
                                    d="M959.4 500L679.8 779.7l279.6 279.7H639.9L360.2 779.7 639.9 500h319.5zM639.9 20.7L120.6 540l159.8 159.8 679-679.1H639.9z" />
                            </defs>
                            <clipPath id="K">
                                <use xlink:href="#J" />
                            </clipPath>
                            <g clip-path="url(#K)">
                                <path d="M360.282 779.645L520.086 619.84 679.9 779.645 520.086 939.45z"
                                    fill="#16b9fd" />
                            </g>
                            <radialGradient id="L" cx="7824.659" cy="-2855.979" r="5082.889"
                                gradientTransform="matrix(0.25,0,0,-0.25,-1812,-622.5)" gradientUnits="userSpaceOnUse">
                                <stop offset="0" stop-color="#fff" stop-opacity=".1" />
                                <stop offset="1" stop-color="#fff" stop-opacity="0" />
                            </radialGradient>
                            <path
                                d="M959.4 500L679.8 779.7l279.6 279.7H639.9L360.2 779.7 639.9 500h319.5zM639.9 20.7L120.6 540l159.8 159.8 679-679.1H639.9z"
                                fill="url(#L)" />
                        </g>
                    </svg>
                </div>
                <span class="logo-text">FinTrack</span>
            </a>
            <nav class="nav-links">
                <a href="#features" class="nav-link">Características</a>
                <a href="#install" class="nav-link">Instalación</a>
                <a href="/privacy-policy" class="nav-link"
                    style="border: 1px solid rgba(255,255,255,0.1); padding: 6px 12px; border-radius: 8px;">Privacidad</a>
            </nav>
        </div>
    </header>

    <!-- Hero Section -->
    <section class="hero">
        <div class="hero-info">
            <div class="badge">100% Independiente & Privada</div>
            <h1 class="hero-title">El control de tus gastos grupales, <span>simplificado</span>.</h1>
            <p class="hero-description">
                Registrá ingresos, egresos y balances de forma colaborativa con tus amigos, pareja o compañeros de
                departamento. Sin registros bancarios complejos, sin invadir tus datos personales.
            </p>

            <!-- Direct Download Container -->
            <div class="download-container">
                <div class="download-header-text">
                    <svg width="16" height="16" viewBox="0 0 24 24">
                        <path
                            d="M19.35 10.04C18.67 6.59 15.64 4 12 4 9.11 4 6.6 5.64 5.35 8.04 2.34 8.36 0 10.91 0 14c0 3.31 2.69 6 6 6h13c2.76 0 5-2.24 5-5 0-2.64-2.05-4.78-4.65-4.96zM17 13l-5 5-5-5h3V9h4v4h3z" />
                    </svg>
                    Descarga Directa de Instaladores
                </div>

                <div class="download-buttons">
                    <!-- Android Direct Download Link -->
                    <a href="/downloads/fintrack.apk" class="btn-download android">
                        <svg viewBox="0 0 24 24">
                            <path
                                d="M17.5 13.5c-.8 0-1.5-.7-1.5-1.5s.7-1.5 1.5-1.5 1.5.7 1.5 1.5-.7 1.5-1.5 1.5m-11 0c-.8 0-1.5-.7-1.5-1.5s.7-1.5 1.5-1.5 1.5.7 1.5 1.5-.7 1.5-1.5 1.5m11.2-5.4L19.4 6c.2-.3.1-.7-.2-.9-.3-.2-.7-.1-.9.2L16.5 7C15.1 6.4 13.6 6 12 6s-3.1.4-4.5 1L5.7 5.3c-.2-.3-.6-.4-.9-.2-.3.2-.4.6-.2.9l1.7 2.1C4.3 9.7 3 12.1 3 14.8c0 .2 0 .3.1.5h17.8c0-.2.1-.3.1-.5 0-2.7-1.3-5.1-3.3-6.7zM12 18c-3.3 0-6.1-2-7.3-4.8h14.6c-1.2 2.8-4 4.8-7.3 4.8z" />
                        </svg>
                        <span>Android (Archivo APK)</span>
                    </a>

                    <!-- iOS Direct Download Link -->
                    <button onclick="toggleIosTooltip()" class="btn-download ios">
                        <svg viewBox="0 0 24 24">
                            <path
                                d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M15.97 4.17c.66-.81 1.11-1.93.99-3.06-1 .04-2.22.67-2.94 1.51-.64.74-1.2 1.88-1.05 2.99 1.12.09 2.26-.53 3-1.44z" />
                        </svg>
                        <span>iOS (Instalador IPA)</span>
                    </button>
                </div>

                <!-- iOS Sideloading instructional collapse -->
                <div id="iosTooltip" class="ios-tooltip-box">
                    🛡️ <strong>Instalación Directa en iOS (iPhone):</strong><br>
                    Debido a las estrictas políticas de Apple, no es posible autoinstalar directamente con un solo clic
                    como en Android.<br><br>
                    Para instalar el archivo IPA en tu iPhone de forma gratuita y sin la App Store, puedes descargar el
                    instalador <strong><a href="/downloads/fintrack.ipa"
                            style="color: var(--accent); text-decoration: underline;">fintrack.ipa aquí</a></strong> y
                    utilizar herramientas seguras de sideloading independientes como <strong>AltStore</strong>,
                    <strong>Scarlet</strong>, o <strong>Sideloadly</strong> desde tu computadora.
                </div>

                <div class="download-notice">
                    <svg width="12" height="12" viewBox="0 0 24 24" fill="currentColor">
                        <path
                            d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-6h2v6zm0-8h-2V7h2v2z" />
                    </svg>
                    <span>Soporte para instalación local. No requiere cuentas comerciales ni pagos a tiendas
                        oficiales.</span>
                </div>
            </div>
        </div>

        <!-- Phone Mockup -->
        <div class="phone-mockup-container">
            <div class="phone-glow"></div>
            <div class="phone-frame">
                <div class="phone-notch"></div>
                <div class="app-screen">
                    <div class="app-header">
                        <div class="app-profile">
                            <div class="app-avatar">FC</div>
                            <div class="app-user-info">
                                <h4>Fer Catalano</h4>
                                <p>Tiktokers Grupo</p>
                            </div>
                        </div>
                        <div class="app-badge-group">Activo</div>
                    </div>

                    <!-- Balance Card -->
                    <div class="app-card">
                        <h5>Balance del Grupo</h5>
                        <div class="app-balance">$ 145,000.00</div>
                        <div class="app-summary">
                            <div class="app-summary-item in">
                                <span class="app-summary-label">Ingresos</span>
                                <span class="app-summary-val">$ 220k</span>
                            </div>
                            <div class="app-summary-item out">
                                <span class="app-summary-label">Egresos</span>
                                <span class="app-summary-val">$ 75k</span>
                            </div>
                        </div>
                    </div>

                    <div class="app-list-title">Movimientos Recientes</div>

                    <!-- Transaction List Simulation -->
                    <div class="app-tx-list">
                        <div class="app-tx-item">
                            <div class="app-tx-left">
                                <div class="app-tx-icon-bg out">▼</div>
                                <div class="app-tx-details">
                                    <h6>Asado grupal</h6>
                                    <p>Hace 2 minutos</p>
                                </div>
                            </div>
                            <div class="app-tx-right">
                                <div class="app-tx-amount out">- $ 25,000</div>
                                <div class="app-tx-user">Fer Catalano</div>
                            </div>
                        </div>

                        <div class="app-tx-item">
                            <div class="app-tx-left">
                                <div class="app-tx-icon-bg in">▲</div>
                                <div class="app-tx-details">
                                    <h6>Fondo Mensual</h6>
                                    <p>Ayer</p>
                                </div>
                            </div>
                            <div class="app-tx-right">
                                <div class="app-tx-amount in">+ $ 120,000</div>
                                <div class="app-tx-user">Matias V.</div>
                            </div>
                        </div>

                        <div class="app-tx-item">
                            <div class="app-tx-left">
                                <div class="app-tx-icon-bg out">▼</div>
                                <div class="app-tx-details">
                                    <h6>Bebidas y Hielo</h6>
                                    <p>Hace 1 hora</p>
                                </div>
                            </div>
                            <div class="app-tx-right">
                                <div class="app-tx-amount out">- $ 12,500</div>
                                <div class="app-tx-user">Lucía Gomez</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Features Grid Section -->
    <section class="features-section" id="features">
        <div class="section-header">
            <div class="badge"
                style="background: rgba(0, 242, 254, 0.1); border-color: rgba(0, 242, 254, 0.25); color: #8BE9FD;">
                Características Clave</div>
            <h2 class="section-title">Finanzas grupales bajo control</h2>
            <p class="section-desc">Diseñamos una herramienta ágil, intuitiva y sumamente elegante enfocada
                exclusivamente en resolver tus cuentas colectivas.</p>
        </div>

        <div class="features-grid">
            <!-- Feature 1 -->
            <div class="feature-card">
                <div class="feature-icon-wrapper">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2" />
                        <circle cx="9" cy="7" r="4" />
                        <path d="M23 21v-2a4 4 0 0 0-3-3.87" />
                        <path d="M16 3.13a4 4 0 0 1 0 7.75" />
                    </svg>
                </div>
                <h3>Grupos Colaborativos</h3>
                <p>Creá grupos financieros (Viajes, Alquiler, Salidas) y compartí códigos de acceso directos para que
                    otros usuarios se unan de inmediato sin fricciones ni logins complejos.</p>
            </div>

            <!-- Feature 2 -->
            <div class="feature-card">
                <div class="feature-icon-wrapper">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <circle cx="12" cy="12" r="10" />
                        <polyline points="12 6 12 12 16 14" />
                    </svg>
                </div>
                <h3>Sincronización en Tiempo Real</h3>
                <p>Con un motor optimizado de consulta inteligente en segundo plano, los movimientos y los saldos del
                    grupo se mantienen actualizados al instante en todos los dispositivos activos.</p>
            </div>

            <!-- Feature 3 -->
            <div class="feature-card">
                <div class="feature-icon-wrapper">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <rect x="3" y="11" width="18" height="11" rx="2" ry="2" />
                        <path d="M7 11V7a5 5 0 0 1 10 0v4" />
                    </svg>
                </div>
                <h3>Soberanía & Privacidad</h3>
                <p>Tu privacidad es sagrada. No leemos contactos, no rastreamos tu ubicación y no accedemos a tus
                    cuentas bancarias. Si eliminas un grupo o tu cuenta, todo se borra para siempre.</p>
            </div>
        </div>
    </section>

    <!-- Direct Installation Steps -->
    <section class="installation-guide" id="install">
        <div class="guide-container">
            <div class="guide-info">
                <h2 class="guide-title">Instalación Local Rápida</h2>
                <p style="color: var(--text-secondary); font-size: 15px;">Instalá FinTrack de manera local e
                    independiente, garantizando el 100% de la propiedad y el control sobre tus binarios compilados.</p>

                <div class="guide-steps">
                    <div class="step-item">
                        <div class="step-number">1</div>
                        <div class="step-text">
                            <h4>Descargá el archivo</h4>
                            <p>Tocá el botón superior de Android (APK) o de iOS (IPA) para guardar el instalador directo
                                en tu dispositivo.</p>
                        </div>
                    </div>

                    <div class="step-item">
                        <div class="step-number">2</div>
                        <div class="step-text">
                            <h4>Permití fuentes desconocidas (Android)</h4>
                            <p>Al abrir el APK, Android te guiará para habilitar "Instalar apps de fuentes desconocidas"
                                para tu navegador. Es un proceso 100% seguro.</p>
                        </div>
                    </div>

                    <div class="step-item">
                        <div class="step-number">3</div>
                        <div class="step-text">
                            <h4>¡Listo para trackear!</h4>
                            <p>Abrí la aplicación, registrá tu cuenta básica de correo e inicia a compartir gastos
                                grupales con total libertad.</p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Simulated QR Scan code -->
            <div class="qr-wrapper">
                <div class="qr-placeholder">
                    <!-- A beautiful pure SVG QR Code mockup pointing to index -->
                    <svg width="140" height="140" viewBox="0 0 29 29" shape-rendering="crispEdges">
                        <path fill="#060913" d="M0 0h29v29H0z" />
                        <path fill="#FFFFFF"
                            d="M1 1h7v7H1zm1 1h5v5H2zM3 3h3v3H3zm8-2h1v1h-1zm1 1h1v1h-1zm-1 1h1v1h-1zm2-2h4v1h-4zm3 2h1v3h-1zm-2 1h1v2h-1zm4-3h1v2h-1zm0 3h1v1h-1zm1 1h1v1h-1zm-2 2h3v1h-3zm1-1h1v1h-1zm-5-3h1v1h-1zm-1 1h1v2h-1zm-1 1h1v1h-1zm3 1h1v1h-1zm1 1h1v1h-1zm-4-1v-1h-1v2h2zm-2-6h1v1h-1zm-1 1h1v1h-1zm0 2h1v1h-1zm4 1h1v1h-1zm1 1h1v2h-1zm-3-10h7v7h-7zm1 1h5v5H21zM22 21h3v3h-3zM1 21h7v7H1zm1 1h5v5H2zm3 3h3v3H3zm8-5h1v1h-1zm1 1h1v1h-1zm-1 1h1v1h-1zm2-2h2v1h-2zm1 2h1v1h-1zm1-2h1v1h-1zm2 1h1v1h-1zm1-1h1v1h-1zm1 1h1v2h-1zm-4 2h1v1h-1zm1 1h1v1h-1zm1-1h1v1h-1zM9 9h1v1H9zm1 1h1v1h-1zm-1 1h1v1H9z" />
                    </svg>
                </div>
                <div style="font-size: 13px; font-weight: 600; color: #FFFFFF;">Escaneá para acceder en el Móvil</div>
                <p style="font-size: 11px; color: var(--text-muted); max-width: 220px; line-height: 1.4;">Escaneá el
                    código QR desde tu smartphone para acceder directamente a la descarga móvil desde el navegador.</p>
            </div>
        </div>
    </section>

    <!-- Footer -->
    <footer>
        <div class="footer-container">
            <div class="logo-group" style="opacity: 0.85;">
                <div class="logo-icon" style="width: 28px; height: 28px; font-size: 14px; border-radius: 7px;">
                    <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"
                        viewBox="0 0 64 64" style="width: 18px; height: 18px;">
                        <g transform="matrix(.061615 0 0 .061615 -1.430818 -1.2754)">
                            <defs>
                                <path id="A"
                                    d="M959.4 500L679.8 779.7l279.6 279.7H639.9L360.2 779.7 639.9 500h319.5zM639.9 20.7L120.6 540l159.8 159.8 679-679.1H639.9z" />
                            </defs>
                            <clipPath id="B">
                                <use xlink:href="#A" />
                            </clipPath>
                            <g clip-path="url(#B)">
                                <path d="M360.3 779.7L520 939.5 959.4 500H639.9z" fill="#39cefd" />
                            </g>
                            <defs>
                                <path id="C"
                                    d="M959.4 500L679.8 779.7l279.6 279.7H639.9L360.2 779.7 639.9 500h319.5zM639.9 20.7L120.6 540l159.8 159.8 679-679.1H639.9z" />
                            </defs>
                            <clipPath id="D">
                                <use xlink:href="#C" />
                            </clipPath>
                            <path clip-path="url(#D)" d="M639.9 20.7h319.5l-679 679.1L120.6 540z" fill="#39cefd" />
                            <defs>
                                <path id="E"
                                    d="M959.4 500L679.8 779.7l279.6 279.7H639.9L360.2 779.7 639.9 500h319.5zM639.9 20.7L120.6 540l159.8 159.8 679-679.1H639.9z" />
                            </defs>
                            <clipPath id="F">
                                <use xlink:href="#E" />
                            </clipPath>
                            <path clip-path="url(#F)" d="M520 939.5l119.9 119.8h319.5L679.8 779.7z" fill="#03569b" />
                            <defs>
                                <path id="G"
                                    d="M959.4 500L679.8 779.7l279.6 279.7H639.9L360.2 779.7 639.9 500h319.5zM639.9 20.7L120.6 540l159.8 159.8 679-679.1H639.9z" />
                            </defs>
                            <clipPath id="H">
                                <use xlink:href="#G" />
                            </clipPath>
                            <linearGradient id="I" gradientUnits="userSpaceOnUse" x1="566.635" y1="970.339" x2="685.65"
                                y2="851.324">
                                <stop offset="0" stop-color="#1a237e" stop-opacity=".4" />
                                <stop offset="1" stop-color="#1a237e" stop-opacity="0" />
                            </linearGradient>
                            <path clip-path="url(#H)" d="M757 857.4l-77.2-77.7L520 939.5z" fill="url(#I)" />
                            <defs>
                                <path id="J"
                                    d="M959.4 500L679.8 779.7l279.6 279.7H639.9L360.2 779.7 639.9 500h319.5zM639.9 20.7L120.6 540l159.8 159.8 679-679.1H639.9z" />
                            </defs>
                            <clipPath id="K">
                                <use xlink:href="#J" />
                            </clipPath>
                            <g clip-path="url(#K)">
                                <path d="M360.282 779.645L520.086 619.84 679.9 779.645 520.086 939.45z"
                                    fill="#16b9fd" />
                            </g>
                            <radialGradient id="L" cx="7824.659" cy="-2855.979" r="5082.889"
                                gradientTransform="matrix(0.25,0,0,-0.25,-1812,-622.5)" gradientUnits="userSpaceOnUse">
                                <stop offset="0" stop-color="#fff" stop-opacity=".1" />
                                <stop offset="1" stop-color="#fff" stop-opacity="0" />
                            </radialGradient>
                            <path
                                d="M959.4 500L679.8 779.7l279.6 279.7H639.9L360.2 779.7 639.9 500h319.5zM639.9 20.7L120.6 540l159.8 159.8 679-679.1H639.9z"
                                fill="url(#L)" />
                        </g>
                    </svg>
                </div>
                <span class="logo-text" style="font-size: 18px;">FinTrack</span>
            </div>
            <div class="footer-links">
                <a href="/privacy-policy" class="footer-link">Política de Privacidad</a>
                <a href="/terms-of-service" class="footer-link">Términos del Servicio</a>
            </div>
            <div class="copyright">
                &copy; 2026 FinTrack. Todos los derechos reservados.<br>
                Construido de forma independiente y privada.
            </div>
        </div>
    </footer>

    <script>
        function toggleIosTooltip() {
            var tooltip = document.getElementById("iosTooltip");
            if (tooltip.style.display === "block") {
                tooltip.style.display = "none";
            } else {
                tooltip.style.display = "block";
            }
        }
    </script>

</body>

</html>