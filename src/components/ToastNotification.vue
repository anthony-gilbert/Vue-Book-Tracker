<template>
  <transition name="toast">
    <div v-if="show" class="toast-notification" :class="type">
      <md-icon class="toast-icon">{{ icon }}</md-icon>
      <span class="toast-message">{{ message }}</span>
    </div>
  </transition>
</template>

<script>
export default {
  name: 'ToastNotification',
  props: {
    message: {
      type: String,
      required: true
    },
    type: {
      type: String,
      default: 'success' // success, info, warning, error
    },
    duration: {
      type: Number,
      default: 3000
    }
  },
  data() {
    return {
      show: false
    };
  },
  computed: {
    icon() {
      const icons = {
        success: 'check_circle',
        info: 'info',
        warning: 'warning',
        error: 'error'
      };
      return icons[this.type] || 'info';
    }
  },
  mounted() {
    this.show = true;
    setTimeout(() => {
      this.show = false;
      setTimeout(() => {
        this.$emit('close');
      }, 300);
    }, this.duration);
  }
};
</script>

<style scoped>
.toast-notification {
  position: fixed;
  top: 20px;
  right: 20px;
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 12px 20px;
  border-radius: 8px;
  color: white;
  font-weight: 500;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  z-index: 1000;
  max-width: 400px;
}

.toast-notification.success {
  background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
}

.toast-notification.info {
  background: linear-gradient(135deg, #17a2b8 0%, #138496 100%);
}

.toast-notification.warning {
  background: linear-gradient(135deg, #ffc107 0%, #e0a800 100%);
  color: #212529;
}

.toast-notification.error {
  background: linear-gradient(135deg, #dc3545 0%, #c82333 100%);
}

.toast-icon {
  font-size: 20px;
}

.toast-message {
  flex-grow: 1;
}

.toast-enter-active, .toast-leave-active {
  transition: all 0.3s ease;
}

.toast-enter {
  transform: translateX(100%);
  opacity: 0;
}

.toast-leave-to {
  transform: translateX(100%);
  opacity: 0;
}

@media (max-width: 768px) {
  .toast-notification {
    top: 10px;
    right: 10px;
    left: 10px;
    max-width: none;
  }
}
</style>