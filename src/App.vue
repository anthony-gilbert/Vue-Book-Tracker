<template>
  <div id="app">
    <!-- Show login page if not authenticated -->
    <LoginPage v-if="!isAuthenticated" @login="handleLogin" />
    
    <!-- Show main app if authenticated -->
    <div v-else>
      <Header 
        msg="Book Tracker" 
        :current-user="currentUser" 
        @logout="handleLogout" 
      />
      
      <div class="main-content">
        <md-tabs md-alignment="centered" class="book-tabs">
          <md-tab id="tab-toread" md-label="To Read" md-icon="bookmark_border">
            <div class="tab-content">
              <Toread 
                :toreadcount="2" 
                @book-updated="handleBookUpdate"
                @book-moved="handleBookMoved"
                :refresh-trigger="refreshTrigger"
              />
            </div>
          </md-tab>
          
          <md-tab id="tab-reading" md-label="Currently Reading" md-icon="menu_book">
            <div class="tab-content">
              <Reading 
                :readingcount="5" 
                @book-updated="handleBookUpdate"
                @book-moved="handleBookMoved"
                :refresh-trigger="refreshTrigger"
              />
            </div>
          </md-tab>
          
          <md-tab id="tab-read" md-label="Books Read" md-icon="done_all">
            <div class="tab-content">
              <Read 
                :readcount="5" 
                @book-updated="handleBookUpdate"
                :refresh-trigger="refreshTrigger"
              />
            </div>
          </md-tab>
        </md-tabs>
      </div>
    </div>

    <!-- Toast Notifications -->
    <ToastNotification
      v-for="toast in toasts"
      :key="toast.id"
      :message="toast.message"
      :type="toast.type"
      @close="removeToast(toast.id)"
    />
  </div>
</template>

<script>
import Header from "./components/Header.vue";
import Toread from "./components/Toread.vue";
import Reading from "./components/Reading.vue";
import Read from "./components/Read.vue";
import LoginPage from "./components/LoginPage.vue";
import ToastNotification from "./components/ToastNotification.vue";
import ApiService from "./services/api.js";
import Vue from 'vue';

export default {
  name: "App",
  components: {
    Header,
    Toread,
    Reading,
    Read,
    LoginPage,
    ToastNotification,
  },
  data() {
    return {
      isAuthenticated: false,
      currentUser: null,
      refreshTrigger: 0, // Used to trigger refreshes in child components
      toasts: [],
      nextToastId: 1,
    };
  },
  async created() {
    // Add API service to Vue prototype for global access
    this.$apiService = ApiService;
    Vue.prototype.$apiService = ApiService;
    
    // Check if user is already logged in
    await this.checkAuthStatus();
  },
  methods: {
    async checkAuthStatus() {
      const token = localStorage.getItem('authToken');
      const userStr = localStorage.getItem('user');
      
      if (token && userStr) {
        try {
          // Verify token is still valid by fetching current user
          const user = await ApiService.getCurrentUser();
          this.currentUser = user;
          this.isAuthenticated = true;
        } catch (error) {
          console.error('Token validation failed:', error);
          // Clear invalid token
          localStorage.removeItem('authToken');
          localStorage.removeItem('user');
          this.isAuthenticated = false;
          this.currentUser = null;
        }
      }
    },
    
    handleLogin(user) {
      this.currentUser = user;
      this.isAuthenticated = true;
    },
    
    handleLogout() {
      this.currentUser = null;
      this.isAuthenticated = false;
    },

    handleBookUpdate() {
      // Increment refresh trigger to notify all child components to refresh
      this.refreshTrigger++;
      console.log('Book updated, triggering refresh for all components');
    },

    handleBookMoved(data) {
      // Show toast notification when book is moved
      const { bookTitle, toStatus } = data;
      const statusNames = {
        'to-read': 'To Read',
        'reading': 'Currently Reading',
        'read': 'Books Read'
      };
      
      this.showToast(
        `"${bookTitle}" moved to ${statusNames[toStatus]}`,
        'success'
      );
      
      // Trigger refresh
      this.handleBookUpdate();
    },

    showToast(message, type = 'info') {
      const toast = {
        id: this.nextToastId++,
        message,
        type
      };
      this.toasts.push(toast);
    },

    removeToast(toastId) {
      this.toasts = this.toasts.filter(toast => toast.id !== toastId);
    }
  }
};
</script>

<style>
body {
  margin: 0;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}

#app {
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  color: #2c3e50;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  min-height: 100vh;
  margin: 0;
  padding: 0;
}

.main-content {
  padding: 20px;
  max-width: 1200px;
  margin: 0 auto;
}

.book-tabs {
  background: rgba(255, 255, 255, 0.95);
  border-radius: 12px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  backdrop-filter: blur(10px);
  margin-top: 20px;
}

.book-tabs .md-tabs-navigation {
  background: rgba(255, 255, 255, 0.9);
  border-radius: 12px 12px 0 0;
}

.book-tabs .md-tab {
  color: #667eea;
  font-weight: 600;
}

.book-tabs .md-tab.md-active {
  color: #764ba2;
}

.tab-content {
  padding: 30px 20px;
  min-height: 500px;
  background: rgba(255, 255, 255, 0.98);
  border-radius: 0 0 12px 12px;
}

/* Responsive design */
@media (max-width: 768px) {
  .main-content {
    padding: 10px;
  }
  
  .tab-content {
    padding: 20px 10px;
  }
}
</style>