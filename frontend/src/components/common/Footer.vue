<script setup lang="ts">
</script>

<template>
  <footer class="bg-brand-navy text-white pt-14 pb-8 border-t border-blue-900/30">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="grid grid-cols-1 md:grid-cols-4 gap-10 pb-12 border-b border-white/10">
        <!-- Col 1: Brand Info -->
        <div class="space-y-4 md:col-span-1">
          <div class="flex items-center gap-3">
            <img src="/img/icon-white.png" alt="PrestasiKu Icon" class="h-9 w-auto" />
            <img src="/img/text-white.png" alt="PrestasiKu Logo" class="h-6 w-auto" />
          </div>
          <p class="text-xs text-slate-300 leading-relaxed">
            Platform manajemen kompetisi dan rekam jejak prestasi pelajar SLTP/SLTA se-Indonesia dengan basis data terverifikasi dan perlindungan privasi.
          </p>
          <div class="flex items-center gap-3 pt-2 text-slate-400">
            <a href="#" class="w-8 h-8 rounded-lg bg-white/5 flex items-center justify-center hover:bg-white/10 hover:text-white transition-colors">
              <i class="fa-brands fa-instagram"></i>
            </a>
            <a href="#" class="w-8 h-8 rounded-lg bg-white/5 flex items-center justify-center hover:bg-white/10 hover:text-white transition-colors">
              <i class="fa-brands fa-youtube"></i>
            </a>
            <a href="#" class="w-8 h-8 rounded-lg bg-white/5 flex items-center justify-center hover:bg-white/10 hover:text-white transition-colors">
              <i class="fa-brands fa-github"></i>
            </a>
          </div>
        </div>

        <!-- Col 2: Navigasi Cepat -->
        <div>
          <h4 class="text-xs font-bold uppercase tracking-wider text-brand-gold mb-4">Navigasi Utama</h4>
          <ul class="space-y-2.5 text-xs text-slate-300">
            <li>
              <router-link to="/" class="hover:text-white transition-colors flex items-center gap-1.5">
                <i class="fa-solid fa-chevron-right text-[9px] text-brand-gold"></i>
                Beranda
              </router-link>
            </li>
            <li>
              <router-link to="/competitions" class="hover:text-white transition-colors flex items-center gap-1.5">
                <i class="fa-solid fa-chevron-right text-[9px] text-brand-gold"></i>
                Katalog Kompetisi
              </router-link>
            </li>
            <li>
              <router-link to="/verify" class="hover:text-white transition-colors flex items-center gap-1.5">
                <i class="fa-solid fa-chevron-right text-[9px] text-brand-gold"></i>
                Cek Verifikasi QR
              </router-link>
            </li>
            <li>
              <router-link to="/school-registration" class="hover:text-white transition-colors flex items-center gap-1.5">
                <i class="fa-solid fa-chevron-right text-[9px] text-brand-gold"></i>
                Pendaftaran Sekolah
              </router-link>
            </li>
          </ul>
        </div>

        <!-- Col 3: Fitur Unggulan -->
        <div>
          <h4 class="text-xs font-bold uppercase tracking-wider text-brand-gold mb-4">Fitur Platform</h4>
          <ul class="space-y-2.5 text-xs text-slate-300">
            <li class="flex items-center gap-2">
              <i class="fa-solid fa-shield-halved text-emerald-400"></i>
              <span>Verified Competition Database</span>
            </li>
            <li class="flex items-center gap-2">
              <i class="fa-solid fa-calculator text-brand-gold"></i>
              <span>Eligibility Engine Otomatis</span>
            </li>
            <li class="flex items-center gap-2">
              <i class="fa-solid fa-lock text-brand-blue"></i>
              <span>Privacy-by-Default Siswa</span>
            </li>
            <li class="flex items-center gap-2">
              <i class="fa-solid fa-qrcode text-purple-400"></i>
              <span>Verifikasi QR Ber-ID Publik</span>
            </li>
          </ul>
        </div>

        <!-- Col 4: Keamanan & Akses -->
        <div>
          <h4 class="text-xs font-bold uppercase tracking-wider text-brand-gold mb-4">Portal Akses</h4>
          <p class="text-xs text-slate-300 mb-3 leading-relaxed">
            Masuk ke portal operasional sesuai peran sekolah atau akun siswa Anda.
          </p>
          <router-link
            to="/login"
            class="inline-flex items-center justify-center gap-2 w-full py-2.5 px-4 bg-brand-gold hover:bg-amber-400 text-brand-navy font-bold text-xs rounded-xl shadow-xs transition-all"
          >
            <i class="fa-solid fa-arrow-right-to-bracket"></i>
            Masuk ke Portal
          </router-link>
        </div>
      </div>

      <!-- Bottom bar -->
      <div class="pt-8 flex flex-col sm:flex-row items-center justify-between text-xs text-slate-400 gap-4">
        <p>&copy; 2026 PrestasiKu. Hak cipta dilindungi undang-undang.</p>
        <p class="flex items-center gap-2">
          <span>Modern & Minimalist Edition</span>
          <span class="w-1.5 h-1.5 rounded-full bg-brand-gold"></span>
          <span>Vue 3 & Tailwind 4</span>
        </p>
      </div>
    </div>
  </footer>
</template>
