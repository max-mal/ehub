import Vue from 'vue/dist/vue.js'
import CommitInfo from './components/project/commitInfo.vue'

window.commitInfoVue = new Vue({
  el: '#commit_info_container',
  components: { CommitInfo }, 
})

function loadAceEditor() {
  return import(/* webpackChunkName: "ace" */ 'ace-builds/src-noconflict/ace').then(() => {
    let a = import(/* webpackChunkName: "ace" */ 'ace-builds/webpack-resolver.js')    
    require('ace-builds/src-noconflict/ext-modelist.js')
    return a
  })
}

loadAceEditor();