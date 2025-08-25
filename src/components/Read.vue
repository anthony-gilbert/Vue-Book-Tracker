<template>
  <div class="read-container">
    <div class="section-header">
      <md-icon class="section-icon">done_all</md-icon>
      <h3>Books Read</h3>
      <span class="book-count">{{ readlists.length }} books</span>
    </div>
    
    <form class="add-book-form" @submit.prevent="addedbook">
      <div class="input-group">
        <BaseInputText 
          v-model="newReadText"
          placeholder="Add a book you have read..."
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
      <md-list v-if="readlists.length" class="book-list">
        <ReadlistItem
          v-for="readlist in readlists"
          :key="readlist.id"
          :readlist="readlist"
          @removeread="deletebook"
        />
      </md-list>
      <div v-else class="empty-state">
        <md-icon class="empty-icon">done_all</md-icon>
        <p>No books completed yet.</p>
        <p class="empty-subtitle">Finish reading some books to see them here!</p>
      </div>
    </div>
  </div>
</template>

<script>
import BaseInputText from './BaseInputText.vue';
import ReadlistItem from './ReadlistItem.vue';

export default {
  name: "Read",
  props: {
    readcount: {
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
    ReadlistItem
  },
  data() {
    return {
      newReadText: "",
      readlists: [],
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
        const response = await this.$apiService.getBooks('read');
        this.readlists = response.books || [];
      } catch (error) {
        console.error('Failed to load books:', error);
      } finally {
        this.loading = false;
      }
    },
    async addedbook() {
      const trimmedText = this.newReadText.trim();
      if (!trimmedText) return;

      try {
        const bookData = {
          title: trimmedText,
          author: '',
          status: 'read'
        };
        
        const newBook = await this.$apiService.createBook(bookData);
        this.readlists.unshift(newBook);
        this.newReadText = "";
        
        // Emit book update to parent
        this.$emit('book-updated');
      } catch (error) {
        console.error('Failed to add book:', error);
      }
    },
    async deletebook(bookId) {
      try {
        await this.$apiService.deleteBook(bookId);
        this.readlists = this.readlists.filter((readlist) => {
          return readlist.id !== bookId;
        });
        
        // Emit book update to parent
        this.$emit('book-updated');
      } catch (error) {
        console.error('Failed to delete book:', error);
      }
    },
  },
};
</script>

<style scoped>
.read-container {
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
  color: #6f42c1;
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
  background: #6f42c1;
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
  background: linear-gradient(135deg, #6f42c1 0%, #9561e2 100%) !important;
  color: white !important;
  border-radius: 8px !important;
  padding: 12px 24px !important;
  font-weight: 600 !important;
  box-shadow: 0 4px 15px rgba(111, 66, 193, 0.3) !important;
  transition: all 0.3s ease !important;
}

.add-button:hover {
  transform: translateY(-2px) !important;
  box-shadow: 0 6px 20px rgba(111, 66, 193, 0.4) !important;
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