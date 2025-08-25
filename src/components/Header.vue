<template>
  <div class="header-container">
    <div class="header-content">
      <div class="header-left">
        <md-avatar class="book-avatar">
          <md-icon class="book-icon">menu_book</md-icon>
        </md-avatar>
        <div class="title-section">
          <h1 class="app-title">{{ msg }}</h1>
          <p class="welcome-text" v-if="currentUser">Welcome back, {{ currentUser.username }}!</p>
        </div>
      </div>
      
      <div class="header-right" v-if="currentUser">
        <div class="user-info">
          <md-avatar class="user-avatar">
            <span class="user-initial">{{ currentUser.username.charAt(0).toUpperCase() }}</span>
          </md-avatar>
          <span class="username">{{ currentUser.username }}</span>
        </div>
        
        <md-button class="md-icon-button logout-btn" @click="handleLogout">
          <md-icon>logout</md-icon>
          <md-tooltip>Logout</md-tooltip>
        </md-button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: "Header",
  props: {
    msg: {
      type: String,
      required: true,
      default: "Book Tracker"
    },
    currentUser: {
      type: Object,
      default: null
    }
  },
  methods: {
    async handleLogout() {
      try {
        await this.$apiService.logout();
      } catch (error) {
        console.error('Logout error:', error);
      } finally {
        // Clear local storage
        localStorage.removeItem('authToken');
        localStorage.removeItem('user');
        
        // Emit logout event
        this.$emit('logout');
      }
    }
  }
};
</script>

<style scoped>
.header-container {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 20px 0;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
  position: relative;
  overflow: hidden;
}

.header-container::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><defs><pattern id="grain" width="100" height="100" patternUnits="userSpaceOnUse"><circle cx="25" cy="25" r="1" fill="rgba(255,255,255,0.1)"/><circle cx="75" cy="75" r="1" fill="rgba(255,255,255,0.1)"/><circle cx="50" cy="10" r="0.5" fill="rgba(255,255,255,0.05)"/></pattern></defs><rect width="100" height="100" fill="url(%23grain)"/></svg>');
  opacity: 0.3;
  pointer-events: none;
}

.header-content {
  display: flex;
  align-items: center;
  justify-content: space-between;
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
  position: relative;
  z-index: 1;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 15px;
}

.book-avatar {
  background: rgba(255, 255, 255, 0.2);
  backdrop-filter: blur(10px);
  border: 2px solid rgba(255, 255, 255, 0.3);
}

.book-icon {
  color: white;
  font-size: 32px;
}

.title-section {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.app-title {
  color: white;
  font-size: 2.5rem;
  font-weight: 300;
  margin: 0;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
  letter-spacing: -0.5px;
}

.welcome-text {
  color: rgba(255, 255, 255, 0.9);
  font-size: 0.9rem;
  margin: 0;
  font-weight: 400;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 15px;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 10px;
  background: rgba(255, 255, 255, 0.1);
  padding: 8px 16px;
  border-radius: 25px;
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.user-avatar {
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.3) 0%, rgba(255, 255, 255, 0.1) 100%);
  border: 2px solid rgba(255, 255, 255, 0.3);
  width: 32px;
  height: 32px;
}

.user-initial {
  color: white;
  font-weight: 600;
  font-size: 14px;
}

.username {
  color: white;
  font-weight: 500;
  font-size: 0.9rem;
}

.logout-btn {
  background: rgba(255, 255, 255, 0.1) !important;
  color: white !important;
  border: 1px solid rgba(255, 255, 255, 0.2) !important;
  backdrop-filter: blur(10px);
  transition: all 0.3s ease !important;
}

.logout-btn:hover {
  background: rgba(255, 255, 255, 0.2) !important;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

@media (max-width: 768px) {
  .header-content {
    padding: 0 15px;
  }
  
  .app-title {
    font-size: 2rem;
  }
  
  .header-left {
    gap: 10px;
  }
  
  .user-info {
    padding: 6px 12px;
  }
  
  .username {
    display: none;
  }
  
  .welcome-text {
    font-size: 0.8rem;
  }
}

@media (max-width: 480px) {
  .app-title {
    font-size: 1.5rem;
  }
  
  .header-left {
    flex-direction: column;
    align-items: flex-start;
    gap: 5px;
  }
  
  .title-section {
    align-items: flex-start;
  }
}
</style>
