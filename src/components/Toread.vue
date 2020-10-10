<template>
  <div>
    <h3>To Read</h3>
    <!-- <p>Total: {{ readingcount }}</p> -->
    <form id="formbox">
      <!-- <md-field class="formboxes" md-inline> -->
        <!-- <label class="formboxes"></label> -->

        <BaseInputText
          v-model="newToreadText"
          placeholder="   Add a book you want to read"
          @keydown.enter="addedbook"
        />

        <md-button
          
          class="md-raised md-primary md-mini addbookbutn formboxes"
          >Add +</md-button
        >
      <!-- </md-field> -->
      <md-list id="toread-list" v-if="toreads.length">
        <ToreadListItem
          v-for="toread in toreads"
          :key="toread.id"
          :toread="toread"
          @remove="deletebook"
        />
      </md-list>
        <p v-else>Nothing left in the list.</p>

      <md-button
        v-on:click="readingbook"
        class="md-raised green-butn md-mini formboxes"
        >Add to Reading</md-button
      >
      <!-- <md-button
        v-on:click="deletebook"
        class="md-raised md-accent md-mini formboxes"
        >Delete</md-button
      > -->
    </form>
  </div>
</template>

<script lang="ts">
import BaseInputText from "./BaseInputText.vue";
import ToreadListItem from "./ToreadListItem.vue";
let nexttoreadId = 1;

export default {
  name: "Toread",
  components: {
    BaseInputText,
    ToreadListItem,
  },
  data() {
    return {
      newToreadText: "",
      toreads: [
        // {
        //   // id: nexttoreadId++,
        //   // text: "Harry Potter",
        // },
      ],
    };
  },
  methods: {
    addedbook(e) {
      e.preventDefault();
      
      const trimmedText = this.newToreadText.trim();
      if (trimmedText) {
        this.toreads.push({
          id: nexttoreadId++,
          text: trimmedText,
        });
        this.newToreadText = "";
      }
    },
    readingbook: function () {
      console.log("added book to reading list");
    },
    deletebook(idToRemove) {
      console.log("deleted book from list");
        this.toreads = this.toreads.filter((toread) => {
        return toread.id !== idToRemove;
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
