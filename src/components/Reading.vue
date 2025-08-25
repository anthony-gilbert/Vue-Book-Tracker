<template>
  <div class="reading-container">
    <div class="section-header">
      <md-icon class="section-icon">menu_book</md-icon>
      <h3>Currently Reading</h3>
      <span class="book-count">{{ readingitems.length }} books</span>
    </div>
    
    <form class="add-book-form" @submit.prevent="addedbook">
      <div class="input-group">
        <BaseInputText 
          v-model="newReadingText"
          placeholder="Add a book you are reading..."
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
      <md-list v-if="readingitems.length" class="book-list">
        <ReadingListItem
          v-for="readingitem in readingitems"
          :key="readingitem.id"
          :readingitem="readingitem"
          @removereading="deletebook"
          @book-moved="handleBookMoved"
        />
      </md-list>
      <div v-else class="empty-state">
        <md-icon class="empty-icon">menu_book</md-icon>
        <p>No books currently being read.</p>
        <p class="empty-subtitle">Start reading something new!</p>
      </div>
    </div>
  </div>
</template>

<script>
import BaseInputText from './BaseInputText.vue';
import ReadingListItem from './ReadingListItem.vue';

export default {
  name: "Reading",
  props: {
    readingcount: {
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
    ReadingListItem
  },
  data() {
    return {
      newReadingText: "",
      readingitems: [],
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
        const response = await this.$apiService.getBooks('reading');
        this.readingitems = response.books || [];
      } catch (error) {
        console.error('Failed to load books:', error);
      } finally {
        this.loading = false;
      }
    },
    async addedbook() {
      const trimmedText = this.newReadingText.trim();
      if (!trimmedText) return;

      try {
        const bookData = {
          title: trimmedText,
          author: '',
          status: 'reading'
        };
        
        const newBook = await this.$apiService.createBook(bookData);
        this.readingitems.unshift(newBook);
        this.newReadingText = "";
        
        // Emit book update to parent
        this.$emit('book-updated');
      } catch (error) {
        console.error('Failed to add book:', error);
      }
    },
    async deletebook(bookId) {
      try {
        await this.$apiService.deleteBook(bookId);
        this.readingitems = this.readingitems.filter((readingitem) => {
          return readingitem.id !== bookId;
        });
        
        // Emit book update to parent
        this.$emit('book-updated');
      } catch (error) {
        console.error('Failed to delete book:', error);
      }
    },
    async handleBookMoved(bookId) {
      // Find the book that was moved
      const movedBook = this.readingitems.find(book => book.id === bookId);
      
      // Remove book from current list when it's moved to another status
      this.readingitems = this.readingitems.filter((readingitem) => {
        return readingitem.id !== bookId;
      });
      
      // Emit book moved event with details
      if (movedBook) {
        this.$emit('book-moved', {
          bookTitle: movedBook.title,
          fromStatus: 'reading',
          toStatus: 'read'
        });
      }
      
      // Emit book update to parent to refresh all components
      this.$emit('book-updated');
    }
  },
};
</script>

<style scoped>
.reading-container {
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
  color: #28a745;
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
  background: #28a745;
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
  background: linear-gradient(135deg, #28a745 0%, #20c997 100%) !important;
  color: white !important;
  border-radius: 8px !important;
  padding: 12px 24px !important;
  font-weight: 600 !important;
  box-shadow: 0 4px 15px rgba(40, 167, 69, 0.3) !important;
  transition: all 0.3s ease !important;
}

.add-button:hover {
  transform: translateY(-2px) !important;
  box-shadow: 0 6px 20px rgba(40, 167, 69, 0.4) !important;
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