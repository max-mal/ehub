import Vue from 'vue/dist/vue.js'
import BranchList from './components/project/branchList.vue'
import FilesList from './components/project/filesList.vue'

global.eventBus = new Vue();

window.projectVue = new Vue({
  el: '#project_container',
  components: { BranchList, FilesList }, 
})

function loadAceEditor() {
  return import(/* webpackChunkName: "ace" */ 'ace-builds/src-noconflict/ace').then(() => {
    let a = import(/* webpackChunkName: "ace" */ 'ace-builds/webpack-resolver.js')    
    require('ace-builds/src-noconflict/ext-modelist.js')
    return a
  })
}

loadAceEditor();