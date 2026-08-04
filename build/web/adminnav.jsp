<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>   
<div class="header">
            <i class="fas fa-bars" style="color: #64748b; font-size: 18px; cursor: pointer;"></i>
            
            <div class="search-container">
                <i class="fas fa-search"></i>
                <input type="text" data-i18n-placeholder="search_placeholder" placeholder="Search for students, teachers, classes...">
            </div>

            <div class="header-right">
                <!-- Dark/Light Mode Toggle Button -->
    <div id="themeToggleBtn" style="cursor: pointer; font-size: 18px; color: #64748b; margin-right: 15px;">
        <i class="fas fa-moon" id="themeIcon"></i>
    </div>
                <!-- Language Selector -->
                <div class="lang-dropdown-wrapper">
                    <div class="lang-select-btn" id="langSelectBtn">
                        <img id="currentLangFlag" src="https://flagcdn.com/w20/us.png" alt="Lang" style="border-radius: 2px;">
                        <span id="currentLangText">English</span>
                        <i class="fas fa-chevron-down" style="font-size: 10px;"></i>
                    </div>
                    <div class="lang-options" id="langOptions">
                        <div class="lang-option" onclick="changeLanguage('en')">
                            <img src="https://flagcdn.com/w20/us.png" width="20" style="border-radius: 2px;"> English
                        </div>
                        <div class="lang-option" onclick="changeLanguage('so')">
                            <img src="https://flagcdn.com/w20/so.png" width="20" style="border-radius: 2px;"> Soomaali
                        </div>
                        <div class="lang-option" onclick="changeLanguage('ar')">
                            <img src="https://flagcdn.com/w20/sa.png" width="20" style="border-radius: 2px;"> العربية
                        </div>
                    </div>
                </div>
                
                <div class="notifications">
                    <i class="far fa-bell"></i>
                    <span class="badge">3</span>
                </div>

                <div class="user-menu">
                    <div style="text-align: right;">
                        <div style="font-size: 13px; font-weight: 600; color: #1e293b;">Admin</div>
                        <div style="font-size: 11px; color: #64748b;" data-i18n="super_admin_short">Super Admin</div>
                    </div>
                    <img src="https://ui-avatars.com/api/?name=Admin&background=e2e8f0&color=1e293b" alt="Profile">
                    <i class="fas fa-chevron-down" style="font-size: 10px; color: #64748b;"></i>
                </div>
            </div>
        </div>