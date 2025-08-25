<template>
  <md-list-item class="book-item">
    <div class="book-content">
      <div class="book-info">
        <h4 class="book-title">{{ readlist.title }}</h4>
        <p v-if="readlist.author" class="book-author">by {{ readlist.author }}</p>
        <p v-if="readlist.date_finished" class="book-date">
          Finished: {{ formatDate(readlist.date_finished) }}
        </p>
      </div>
      <div class="book-actions">
        <md-button class="md-icon-button md-accent delete-btn" @click="deleteBook">
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
    readlist: {
      type: Object,
      required: true,
    },
  },
  methods: {
    deleteBook() {
      this.$emit('removeread', this.readlist.id);
    },
    formatDate(dateString) {
      if (!dateString) return '';
      const date = new Date(dateString);
      return date.toLocaleDateString();
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
  margin: 0 0 4px 0;
  font-size: 0.9rem;
  color: #666;
  font-style: italic;
}

.book-date {
  margin: 0;
  font-size: 0.8rem;
  color: #999;
}

.book-actions {
  display: flex;
  gap: 8px;
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
</style>