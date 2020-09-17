<template>
  <div id="app">
    <h3>Reading</h3>
    <span>Total: {{readingcount}}</span>
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
  name: 'Reading',
  props: {
      readingcount: Number
  }
}
</script>

<style>
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
