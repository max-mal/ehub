<template>
  <div class="commit_info"> 
      <p>{{ info.message }}</p>
      <p><i>{{ info.commit }} {{ info.commit_date }}</i></p>
     <div class="row files_list">
         <div class="col-md-12 files_list__file" v-for="file,fileIndex in diff" :key="file.a_path + file.b_path">
             <div class="files_list__file__desc">
                <div class="files_list__file__name">{{ getFileName(file) }}</div>
                <i v-if="file.new_mode">File created {{ file.new_mode }}</i>
                <i v-if="file.deleted_mode">File deleted</i>
                <i v-if="file.old_mode">File permissions changed {{ file.old_mode }} -> {{ file.new_mode }}</i>
                <i v-if="file.rename_from">File renamed {{ file.rename_from }} -> {{ file.rename_to }}</i>
             </div>

             <div class="files_list__file__hunks">
                 <div class="files_list__file__hunk" v-for="hunk,index in file.hunks" :key="index">
                     <p class="files_list__file__hunk__signature">@@ {{ diff[fileIndex].hunk_signatures[index].start }} {{ diff[fileIndex].hunk_signatures[index].end }} @@</p>
                    <div class="files_list__file__hunk__editor" :id="`file_${fileIndex}_hunk_${index}`">{{ filterHunk(hunk) }}</div>
                 </div>
             </div>
         </div>
     </div>
  </div>
</template>

<script>
  export default {
    props: [
      'name',
      'namespace',
      'hash',
    ],
    data () {
      return {
        diff: null,
        info: null,
      }
    },
    methods: {
        initEditors() {
            if (!window.ace) {
                return setTimeout(() => {
                    this.initEditors()
                }, 500) 
            }
            
            let Range = ace.require('ace/range').Range;

            for (let file in this.diff) {
                let fileObj = this.diff[file]
                for (let hunk in fileObj.hunks) {
                    let id = `file_${file}_hunk_${hunk}`
                    
                    let editor = ace.edit(id);
                    editor.setOptions({
                        maxLines: Infinity,
                        showLineNumbers: false,
                        readOnly: true,
                        highlightActiveLine: false,
                        highlightGutterLine: false,
                    });
                    editor.getSession().setUseWorker(false);
                    editor.setTheme("ace/theme/monokai");
                    editor.session.setMode("ace/mode/javascript");

                    let modelist = ace.require("ace/ext/modelist")        
                    let mode = modelist.getModeForPath(this.getFileName(fileObj)).mode
                    editor.session.setMode(mode)

                    let lines = fileObj.hunks[hunk].split('\n')
                    lines.forEach((line, lineIndex) => {                        
                        if (line[0] == "+") {
                            editor.session.addMarker(new Range(lineIndex, 0, lineIndex, 1), "addition_marker", "fullLine");
                        }

                        if (line[0] == "-") {
                           editor.session.addMarker(new Range(lineIndex, 0, lineIndex, 1), "deletion_marker", "fullLine"); 
                        }
                    })
                }
            }
        },
        getFileName(file) {
            return file.a_path == '/dev/null'? file.b_path : file.a_path
        },
        filterHunk(hunk) {
            return hunk.split('\n').map((line) => line.substr(1)).join('\n')
        }
    },
    mounted: function() {
      let self = this
      $.get(`/project/${self.namespace}/${self.name}/commit/${self.hash}/json`, function(data) {
        self.diff = data.files
        self.info = data.info
        self.$nextTick(() => {
            self.initEditors();
        });
      })
    }
  }
</script>
