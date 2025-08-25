<template>
  <div class="toread-container">
    <div class="section-header">
      <md-icon class="section-icon">bookmark_border</md-icon>
      <h3>Books to Read</h3>
      <span class="book-count">{{ toreads.length }} books</span>
    </div>
    
    <form class="add-book-form" @submit.prevent="addedbook">
      <div class="input-group">
        <BaseInputText
          v-model="newToreadText"
          placeholder="Add a book you want to read..."
          class="book-input"
        />
        <md-button
          type="submit"
          class="md-raised md-primary add-button"
        >
          <md-icon>add</md-icon>
          Add Book
        </md-button>
      </div>
    </form>

    <div class="books-list">
      <md-list v-if="toreads.length" class="book-list">
        <ToreadListItem
          v-for="toread in toreads"
          :key="toread.id"
          :toread="toread"
          @remove="deletebook"
          @book-moved="handleBookMoved"
        />
      </md-list>
      <div v-else class="empty-state">
        <md-icon class="empty-icon">bookmark_border</md-icon>
        <p>No books in your reading list yet.</p>
        <p class="empty-subtitle">Add some books you'd like to read!</p>
      </div>
    </div>
  </div>
</template>

<script>
import BaseInputText from "./BaseInputText.vue";
import ToreadListItem from "./ToreadListItem.vue";

export default {
  name: "Toread",
  props: {
    toreadcount: {
      type: Number,
      default: 0
    },
    refreshTrigger: {
      type: Number,
      default: 0
    }
  },
  components: {
    BaseInputText,
    ToreadListItem,
  },
  data() {
    return {
      newToreadText: "",
      toreads: [],
      loading: false,
    };
  },
  async mounted() {
    await this.loadBooks();
  },
  watch: {
    refreshTrigger() {
      // Reload books when refresh trigger changes
      this.loadBooks();
    }
  },
  methods: {
    async loadBooks() {
      try {
        this.loading = true;
        const response = await this.$apiService.getBooks('to-read');
        this.toreads = response.books || [];
      } catch (error) {
        console.error('Failed to load books:', error);
      } finally {
        this.loading = false;
      }
    },
    async addedbook() {
      const trimmedText = this.newToreadText.trim();
      if (!trimmedText) return;

      try {
        const bookData = {
          title: trimmedText,
          author: '',
          status: 'to-read'
        };
        
        const newBook = await this.$apiService.createBook(bookData);
        this.toreads.unshift(newBook);
        this.newToreadText = "";
        
        // Emit book update to parent
        this.$emit('book-updated');
      } catch (error) {
        console.error('Failed to add book:', error);
      }
    },
    async deletebook(bookId) {
      try {
        await this.$apiService.deleteBook(bookId);
        this.toreads = this.toreads.filter((toread) => {
          return toread.id !== bookId;
        });
        
        // Emit book update to parent
        this.$emit('book-updated');
      } catch (error) {
        console.error('Failed to delete book:', error);
      }
    },
    async handleBookMoved(bookId) {
      // Find the book that was moved
      const movedBook = this.toreads.find(book => book.id === bookId);
      
      // Remove book from current list when it's moved to another status
      this.toreads = this.toreads.filter((toread) => {
        return toread.id !== bookId;
      });
      
      // Emit book moved event with details
      if (movedBook) {
        this.$emit('book-moved', {
          bookTitle: movedBook.title,
          fromStatus: 'to-read',
          toStatus: 'reading'
        });
      }
      
      // Emit book update to parent to refresh all components
      this.$emit('book-updated');
    }
  },
};
</script>

<style scoped>
.toread-container {
  max-width: 800px;
  margin: 0 auto;
}

.section-header {
  display: flex;
  align-items: center;
  margin-bottom: 30px;
  padding-bottom: 15px;
  border-bottom: 2px solid #e0e0e0;
}

.section-icon {
  color: #667eea;
  font-size: 28px;
  margin-right: 10px;
}

.section-header h3 {
  margin: 0;
  flex-grow: 1;
  color: #2c3e50;
  font-size: 1.8rem;
  font-weight: 600;
}

.book-count {
  background: #667eea;
  color: white;
  padding: 5px 12px;
  border-radius: 20px;
  font-size: 0.9rem;
  font-weight: 500;
}

.add-book-form {
  margin-bottom: 30px;
}

.input-group {
  display: flex;
  gap: 15px;
  align-items: flex-end;
}

.book-input {
  flex-grow: 1;
}

.add-button {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%) !important;
  color: white !important;
  border-radius: 8px !important;
  padding: 12px 24px !important;
  font-weight: 600 !important;
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3) !important;
  transition: all 0.3s ease !important;
}

.add-button:hover {
  transform: translateY(-2px) !important;
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4) !important;
}

.books-list {
  min-height: 200px;
}

.book-list {
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

.empty-state {
  text-align: center;
  padding: 60px 20px;
  color: #666;
}

.empty-icon {
  font-size: 64px;
  color: #ddd;
  margin-bottom: 20px;
}

.empty-state p {
  margin: 10px 0;
  font-size: 1.1rem;
}

.empty-subtitle {
  color: #999;
  font-size: 0.95rem !important;
}

@media (max-width: 768px) {
  .input-group {
    flex-direction: column;
    gap: 10px;
  }
  
  .section-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 10px;
  }
  
  .book-count {
    align-self: flex-start;
  }
}
</style>
