<template>
  <md-list-item class="book-item" :class="{ 'moving': isMoving }">
    <div class="book-content">
      <div class="book-info">
        <h4 class="book-title">{{ readingitem.title }}</h4>
        <p v-if="readingitem.author" class="book-author">by {{ readingitem.author }}</p>
        <p v-if="isMoving" class="moving-text">Marking as Read...</p>
      </div>
      <div class="book-actions">
        <md-button 
          class="md-icon-button md-primary finish-reading-btn" 
          @click="finishReading"
          :disabled="isMoving"
        >
          <md-progress-spinner v-if="isMoving" md-mode="indeterminate" :md-diameter="20"></md-progress-spinner>
          <md-icon v-else>done</md-icon>
          <md-tooltip v-if="!isMoving">Mark as Read</md-tooltip>
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
    readingitem: {
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
    async finishReading() {
      this.isMoving = true;
      try {
        await this.$apiService.updateBookStatus(this.readingitem.id, 'read');
        console.log(`Book "${this.readingitem.title}" moved to read`);
        
        // Small delay to show the moving state
        setTimeout(() => {
          this.$emit('book-moved', this.readingitem.id);
        }, 500);
      } catch (error) {
        console.error('Failed to update book status:', error);
        this.isMoving = false;
      }
    },
    deleteBook() {
      this.$emit('removereading', this.readingitem.id);
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

.finish-reading-btn {
  background: linear-gradient(135deg, #6f42c1 0%, #9561e2 100%) !important;
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
  color: #6f42c1;
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