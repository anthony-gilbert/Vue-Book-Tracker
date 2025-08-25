<template>
  <md-list-item class="book-item" :class="{ 'moving': isMoving }">
    <div class="book-content">
      <div class="book-info">
        <h4 class="book-title">{{ toread.title }}</h4>
        <p v-if="toread.author" class="book-author">by {{ toread.author }}</p>
        <p v-if="isMoving" class="moving-text">Moving to Reading...</p>
      </div>
      <div class="book-actions">
        <md-button 
          class="md-icon-button md-primary start-reading-btn" 
          @click="startReading"
          :disabled="isMoving"
        >
          <md-progress-spinner v-if="isMoving" md-mode="indeterminate" :md-diameter="20"></md-progress-spinner>
          <md-icon v-else>play_arrow</md-icon>
          <md-tooltip v-if="!isMoving">Start Reading</md-tooltip>
        </md-button>
        <md-button class="md-icon-button md-accent delete-btn" @click="deleteBook" :disabled="isMoving">
          <md-icon>delete</md-icon>
          <md-tooltip>Delete</md-tooltip>
        </md-button>
      </div>
    </div>
  </md-list-item>
</template>

<script>
export default {
  props: {
    toread: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      isMoving: false
    };
  },
  methods: {
    async startReading() {
      this.isMoving = true;
      try {
        await this.$apiService.updateBookStatus(this.toread.id, 'reading');
        console.log(`Book "${this.toread.title}" moved to reading`);
        
        // Small delay to show the moving state
        setTimeout(() => {
          this.$emit('book-moved', this.toread.id);
        }, 500);
      } catch (error) {
        console.error('Failed to update book status:', error);
        this.isMoving = false;
      }
    },
    deleteBook() {
      this.$emit('remove', this.toread.id);
    }
  }
};
</script>
<style scoped>
.book-item {
  padding: 16px;
  border-bottom: 1px solid #e0e0e0;
  transition: background-color 0.2s ease;
}

.book-item:hover {
  background-color: #f8f9fa;
}

.book-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
}

.book-info {
  flex-grow: 1;
}

.book-title {
  margin: 0 0 4px 0;
  font-size: 1.1rem;
  font-weight: 600;
  color: #2c3e50;
}

.book-author {
  margin: 0;
  font-size: 0.9rem;
  color: #666;
  font-style: italic;
}

.book-actions {
  display: flex;
  gap: 8px;
}

.start-reading-btn {
  background: linear-gradient(135deg, #28a745 0%, #20c997 100%) !important;
  color: white !important;
}

.delete-btn {
  background: linear-gradient(135deg, #dc3545 0%, #c82333 100%) !important;
  color: white !important;
}

@media (max-width: 768px) {
  .book-content {
    flex-direction: column;
    align-items: flex-start;
    gap: 12px;
  }
  
  .book-actions {
    align-self: flex-end;
  }
}

.book-item.moving {
  opacity: 0.7;
  background-color: #f0f8ff;
}

.moving-text {
  color: #667eea;
  font-size: 0.8rem;
  font-weight: 500;
  margin: 4px 0 0 0;
  animation: pulse 1.5s infinite;
}

@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.5; }
}
</style>