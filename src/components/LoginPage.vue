<template>
  <div class="login-container">
    <div class="login-card">
      <div class="login-header">
        <md-icon class="login-icon">menu_book</md-icon>
        <h1>Book Tracker</h1>
        <p>Track your reading journey</p>
      </div>

      <div class="login-form">
        <md-tabs md-alignment="centered" class="auth-tabs">
          <md-tab id="tab-login" md-label="Login">
            <form @submit.prevent="handleLogin" class="auth-form">
              <md-field class="form-field" :class="{ 'md-invalid': loginErrors.username }">
                <label>Username</label>
                <md-input v-model="loginForm.username" required></md-input>
                <span class="md-error" v-if="loginErrors.username">{{ loginErrors.username }}</span>
              </md-field>

              <md-field class="form-field" :class="{ 'md-invalid': loginErrors.password }">
                <label>Password</label>
                <md-input v-model="loginForm.password" type="password" required></md-input>
                <span class="md-error" v-if="loginErrors.password">{{ loginErrors.password }}</span>
              </md-field>

              <md-button 
                type="submit" 
                class="md-raised md-primary login-button"
                :disabled="loginLoading"
              >
                <md-progress-spinner v-if="loginLoading" md-mode="indeterminate" :md-diameter="20"></md-progress-spinner>
                <span v-else>Login</span>
              </md-button>

              <div v-if="loginError" class="error-message">
                {{ loginError }}
              </div>
            </form>
          </md-tab>

          <md-tab id="tab-register" md-label="Register">
            <form @submit.prevent="handleRegister" class="auth-form">
              <md-field class="form-field" :class="{ 'md-invalid': registerErrors.username }">
                <label>Username</label>
                <md-input v-model="registerForm.username" required></md-input>
                <span class="md-error" v-if="registerErrors.username">{{ registerErrors.username }}</span>
              </md-field>

              <md-field class="form-field" :class="{ 'md-invalid': registerErrors.email }">
                <label>Email</label>
                <md-input v-model="registerForm.email" type="email" required></md-input>
                <span class="md-error" v-if="registerErrors.email">{{ registerErrors.email }}</span>
              </md-field>

              <md-field class="form-field" :class="{ 'md-invalid': registerErrors.password }">
                <label>Password</label>
                <md-input v-model="registerForm.password" type="password" required></md-input>
                <span class="md-error" v-if="registerErrors.password">{{ registerErrors.password }}</span>
              </md-field>

              <md-button 
                type="submit" 
                class="md-raised md-primary login-button"
                :disabled="registerLoading"
              >
                <md-progress-spinner v-if="registerLoading" md-mode="indeterminate" :md-diameter="20"></md-progress-spinner>
                <span v-else>Register</span>
              </md-button>

              <div v-if="registerError" class="error-message">
                {{ registerError }}
              </div>
            </form>
          </md-tab>
        </md-tabs>
      </div>
    </div>
  </div>
</template>

<script>
import ApiService from '../services/api';

export default {
  name: 'LoginPage',
  data() {
    return {
      loginForm: {
        username: '',
        password: ''
      },
      registerForm: {
        username: '',
        email: '',
        password: ''
      },
      loginLoading: false,
      registerLoading: false,
      loginError: '',
      registerError: '',
      loginErrors: {},
      registerErrors: {}
    };
  },
  methods: {
    async handleLogin() {
      this.loginLoading = true;
      this.loginError = '';
      this.loginErrors = {};

      try {
        const response = await ApiService.login(this.loginForm);
        
        // Store token and user info
        localStorage.setItem('authToken', response.token);
        localStorage.setItem('user', JSON.stringify(response.user));
        
        // Emit login event to parent
        this.$emit('login', response.user);
        
      } catch (error) {
        console.error('Login failed:', error);
        if (error.message.includes('401')) {
          this.loginError = 'Invalid username or password';
        } else if (error.message.includes('400')) {
          this.loginError = 'Please fill in all required fields';
        } else {
          this.loginError = 'Login failed. Please try again.';
        }
      } finally {
        this.loginLoading = false;
      }
    },

    async handleRegister() {
      this.registerLoading = true;
      this.registerError = '';
      this.registerErrors = {};

      console.log('Attempting registration with:', {
        username: this.registerForm.username,
        email: this.registerForm.email,
        password: '***'
      });

      try {
        const response = await ApiService.register(this.registerForm);
        console.log('Registration successful:', response);
        
        // Store token and user info
        localStorage.setItem('authToken', response.token);
        localStorage.setItem('user', JSON.stringify(response.user));
        
        // Emit login event to parent
        this.$emit('login', response.user);
        
      } catch (error) {
        console.error('Registration failed:', error);
        console.error('Error details:', {
          message: error.message,
          status: error.status,
          stack: error.stack
        });
        
        // Parse error response for better error messages
        if (error.status === 409) {
          this.registerError = 'Username or email already exists';
        } else if (error.status === 400) {
          this.registerError = error.message || 'Please check your input. Username must be 3+ characters, password must be 6+ characters.';
        } else if (error.status === 500) {
          this.registerError = 'Server error. Please try again later.';
        } else if (error.message.includes('Failed to fetch') || error.message.includes('NetworkError')) {
          this.registerError = 'Cannot connect to server. Please make sure the backend is running.';
        } else {
          this.registerError = `Registration failed: ${error.message}`;
        }
      } finally {
        this.registerLoading = false;
      }
    }
  }
};
</script>

<style scoped>
.login-container {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
}

.login-card {
  background: rgba(255, 255, 255, 0.95);
  border-radius: 16px;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
  backdrop-filter: blur(10px);
  width: 100%;
  max-width: 450px;
  overflow: hidden;
}

.login-header {
  text-align: center;
  padding: 40px 30px 20px;
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.1) 0%, rgba(118, 75, 162, 0.1) 100%);
}

.login-icon {
  font-size: 48px;
  color: #667eea;
  margin-bottom: 10px;
}

.login-header h1 {
  margin: 0 0 10px;
  color: #2c3e50;
  font-size: 2rem;
  font-weight: 300;
}

.login-header p {
  margin: 0;
  color: #666;
  font-size: 1rem;
}

.login-form {
  padding: 20px 30px 40px;
}

.auth-tabs {
  background: transparent;
}

.auth-tabs .md-tabs-navigation {
  background: transparent;
}

.auth-form {
  padding: 30px 0 20px;
}

.form-field {
  margin-bottom: 20px;
}

.form-field .md-input {
  font-size: 16px;
}

.login-button {
  width: 100%;
  height: 48px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%) !important;
  color: white !important;
  border-radius: 8px !important;
  font-weight: 600 !important;
  font-size: 16px !important;
  margin-top: 20px;
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3) !important;
  transition: all 0.3s ease !important;
}

.login-button:hover:not(:disabled) {
  transform: translateY(-2px) !important;
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4) !important;
}

.login-button:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}

.error-message {
  background: #ffebee;
  color: #c62828;
  padding: 12px 16px;
  border-radius: 8px;
  margin-top: 16px;
  font-size: 14px;
  border-left: 4px solid #c62828;
}

.md-progress-spinner {
  margin-right: 8px;
}

@media (max-width: 480px) {
  .login-container {
    padding: 10px;
  }
  
  .login-card {
    max-width: 100%;
  }
  
  .login-header {
    padding: 30px 20px 15px;
  }
  
  .login-form {
    padding: 15px 20px 30px;
  }
  
  .login-header h1 {
    font-size: 1.5rem;
  }
}
</style>