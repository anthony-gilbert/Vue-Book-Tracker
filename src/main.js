import Vue from 'vue'
import App from './App.vue'
import Vuex from 'vuex'
import VueMaterial from 'vue-material'
import 'vue-material/dist/vue-material.min.css'
import 'vue-material/dist/theme/default.css'
import 'es6-promise/auto'
import VueRouter from 'vue-router'
import router from './router'

Vue.use(Vuex)
Vue.use(VueMaterial)
Vue.use(VueRouter)

Vue.config.productionTip = false

new Vue({
  router,
  render: h => h(App)
}).$mount('#app')

