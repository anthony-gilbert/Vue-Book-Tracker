<template>
  <div>
    <h3>Currently Reading</h3>
    <!-- <p>Total: {{readingcount}}</p> -->
    <form id="formbox">
      <!-- <md-field class="formboxes" md-inline> -->
        <!-- <label class="formboxes">Add a book you are reading</label> -->
        <BaseInputText 
          v-model="newReadingText"
          placeholder="   Add a book you are reading"
          @keydown.enter="addedbook"
        />

        <md-button
          v-on:click="addedbook"
          class="md-raised md-primary md-mini addbookbutn formboxes"
          >Add +</md-button
        >
      <!-- </md-field> -->
      <md-list id="reading-list" v-if="readingitems.length">
        <ReadingListItem
          v-for="readingitem in readingitems"
          :key="readingitem.id"
          :readingitem="readingitem"
          @removereading="deletebook"
        />
      </md-list>
      <p v-else>Nothing left in the list.</p>

      <md-button
        @click="readingbook"
        class="md-raised green-butn md-mini formboxes"
        >Finished Reading</md-button
      >
    </form>
  </div>
</template>

<script lang="ts">
import BaseInputText from './BaseInputText.vue';
import ReadingListItem from './ReadingListItem.vue';
let nextReadingId = 1;

export default {
  name: "Reading",
  components: {
    BaseInputText,
    ReadingListItem
  },
  data() {
    return {
      newReadingText: "",
      readingitems: [
        // {
        //   id: nextreadId++,
        //   text: "Harry Potter",
        // },
      ],
    };
  },
  methods: {
    addedbook(e) {
      e.preventDefault();
      
      const trimmedText = this.newReadingText.trim();
      if (trimmedText) {
        this.readingitems.push({
          id: nextReadingId++,
          text: trimmedText,
        });
        this.newReadingText = "";
      }
    },
    readingbook() {
      console.log("added book to reading list");
    },
    deletebook(idToRemove) {
        console.log("deleted book from list");
        this.readingitems = this.readingitems.filter((readingitem) => {
        return readingitem.id !== idToRemove;
      });
    },
  },
};
</script>

<style scoped>
h3 {
  margin: 40px 0 0;
}
a {
  color: #42b983;
}
#formbox {
  padding-left: 20%;
  padding-right: 20%;
}
.formboxes {
  background-color: white;
}
.green-butn {
  background-color: yellowgreen !important;
  color: white !important;
}
label {
  padding-left: 1em;
}
.addbookbutn {
  margin-top: -10px;
}
</style>
