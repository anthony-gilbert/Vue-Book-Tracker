<template>
  <div class="hello">
    <h1>{{ msg }}</h1>
    <p>Keep track of the books you read.</p>
    <h3>To Read</h3>
    <ul>
      <li>Book Title</li>
      <li>Book Title</li>
    </ul>
    <h3>Reading</h3>
    <ul>
      <li>Book Title</li>
      <li>Book Title</li>
      <li>Book Title</li>
      <li>Book Title</li>
      <li>Book Title</li>
    </ul>
    <h3>Read</h3>
    <ul>
      <li>Book Title</li>
      <li>Book Title</li>
      <li>Book Title</li>
      <li>Book Title</li>
      <li>Book Title</li>
    </ul>
  </div>
</template>

<script>
export default {
  name: "HelloWorld",
  props: {
    msg: String,
  },
};
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
h3 {
  margin: 40px 0 0;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  display: inline-block;
  margin: 0 10px;
}
a {
  color: #42b983;
}
</style>
