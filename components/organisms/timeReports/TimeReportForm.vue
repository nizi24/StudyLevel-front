<template>
  <ValidationObserver ef="obs" v-slot="{ passes }">
    <v-card>
      <v-card-title class="headline">
        <span
        v-if="editInitialValue"
        >記録を編集する</span>
        <span
        v-else
        >時間を記録する</span>
      </v-card-title>
      <v-form>
        <v-card-text>
          <v-container class="time-report-form-card-text">
            <v-row>
              <span class="study-date-title">学習日時</span>
            </v-row>
            <v-row
            style="position: relative"
            >
              <v-col
              sm="3"
              cols="5"
              @click="datePicker = !datePicker"
              >
                <v-row justify="center" style="margin-top: 20px">
                  <span style="font-size: 1.4em">
                    {{ studyDate }}
                  </span>
                </v-row>
              </v-col>
              <ValidationProvider
              vid="学習日時"
              >
                <input type="hidden" v-model="studyDate"/>
                <v-date-picker
                v-if="datePicker"
                v-model="studyDate"
                locale="ja"
                id="datePicker"
                :allowed-dates="allowedDates"
                @input="datePicker = false"
                ></v-date-picker>
              </ValidationProvider>
              <v-col lg="2" sm="3" cols="4">
                <VAutoCompleteWithValidation
                rules="max_value:23|validDate:@分 ,@学習日時"
                v-model="studyDateHour"
                label="時 "
                :items="hours"
                />
              </v-col>
              <v-col lg="2" cols="3">
                <VAutoCompleteWithValidation
                rules="max_value:59|validDateMinutes:@時 ,@学習日時"
                v-model="studyDateMinute"
                label="分 "
                :items="minutes"
                />
              </v-col>
            </v-row>
            <v-row>
              <v-col sm="4" cols="6">
                <VAutoCompleteWithValidation
                rules="validTime:@分"
                v-model="hour"
                label="学習時間"
                :items="hours"
                />
              </v-col>
              <v-col sm="4" cols="6">
                <VAutoCompleteWithValidation
                rules="max_value:60|validTime:@学習時間"
                v-model="minute"
                label="分"
                :items="minutes"
                />
              </v-col>
            </v-row>
            <TagsInput
            v-model="tag"
            :initTags="tags"
            @tags-changed="newTags => tags = newTags"
            />
            <v-row>
              <v-col cols="12">
                <VTextAreaWithValidation
                rules="max:280"
                :counter="280"
                label="メモ・学習内容"
                v-model="memo"
                />
              </v-col>
            </v-row>
          </v-container>
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn color="blue darken-1" text @click="closeModal">Close</v-btn>
          <v-btn
          color="blue darken-1"
          text
          @click="passes(record)"
          id="save"
          :disabled="disabled"
          >Save</v-btn>
        </v-card-actions>
      </v-form>
    </v-card>
    <ExpReductionAlert
    :displayModal="displayAlert"
    @cancel="cancel"
    @understanding="understanding"
    />
  </ValidationObserver>
</template>

<script>
import { ValidationObserver } from 'vee-validate' // テスト用にインポート
import VAutoCompleteWithValidation from '../../molecules/inputs/VAutoCompleteWithValidation.vue'
import VTextAreaWithValidation from '../../molecules/inputs/VTextAreaWithValidation.vue'
import TagsInput from '../../molecules/inputs/TagsInput.vue'
import ExpReductionAlert from '../ExpReductionAlert.vue'

export default {
  components: {
    VAutoCompleteWithValidation,
    VTextAreaWithValidation,
    ExpReductionAlert,
    ValidationObserver,
    TagsInput
  },
  props: {
    editInitialValue: {
      type: Object
    },
    initStudyDateHours: {
      type: String,
      default: new Date().getHours().toString()
    },
    initStudyDateMinutes: {
      type: String,
      default: new Date().getMinutes().toString()
    }
  },
  data () {
    return {
      hour: '',
      minute: '',
      memo: '',
      displayAlert: false,
      tag: '',
      studyDate: new Date().toLocaleDateString().replace(/\//g, '-'),
      studyDateHour: this.initStudyDateHours,
      studyDateMinute: this.initStudyDateMinutes,
      tags: [],
      disabled: false,
      datePicker: false
    }
  },
  computed: {
    timeProcess () {
      return this.hour + ':' + this.minute
    },
    hours () {
      const hours = []
      for (let i = 0; i < 24; i++) { hours.push(i.toString()) }
      return hours
    },
    minutes () {
      const minutes = []
      for (let i = 0; i < 60; i++) { minutes.push(i.toString()) }
      return minutes
    },
    tagsProcessing () {
      let tags = this.editInitialValue.tags
      tags = tags.map((value) => {
        return { text: value.name, tiClasses: ['ti-valid'] }
      })
      return tags
    },
    studyDateProcessing () {
      return this.studyDate.toString() + ' ' + this.studyDateHour +
        ':' + this.studyDateMinute
    }
  },
  methods: {
    record () {
      if (this.disabled) { return }
      this.disabled = true
      const timeReport = {
        study_time: this.timeProcess,
        memo: this.memo,
        study_date: this.studyDateProcessing
      }
      const tags = {
        tags: this.tags
      }
      // 再編集の場合
      if (this.editInitialValue) {
        timeReport.id = this.editInitialValue.id
        // 経験値が減る場合は警告を出す
        const oldExp = this.editInitialValue.experience_record.experience_point
        const nexExp = Number(this.hour) * 60 + Number(this.minute)
        if (oldExp > nexExp) {
          this.displayAlert = true
        } else {
          this.$emit('record', { timeReport, tags })
        }
      } else {
        this.$emit('record', { timeReport, tags })
        this.hour = '0'
        this.minute = '1'
        this.memo = ''
        this.tags = []
        this.studyDate = this.dateFormat(new Date())
        this.studyDateHour = new Date().getHours().toString()
        this.studyDateMinute = new Date().getMinutes().toString()
      }
      setTimeout(() => {
        this.disabled = false
      }, 200)
    },
    closeModal () {
      this.$emit('closeModal')
    },
    cancel () {
      this.displayAlert = false
    },
    understanding () {
      const timeReport = {
        study_time: this.timeProcess,
        memo: this.memo,
        id: this.editInitialValue.id
      }
      const tags = {
        tags: this.tags
      }
      this.displayAlert = false
      this.$emit('record', { timeReport, tags })
    },
    allowedDates (val) {
      const today = new Date()
      let week = []
      week.unshift(new Date(today))
      for (let i = 0; i < 7; i++) {
        week.unshift(new Date(today.setDate(today.getDate() - 1)))
      }
      const that = this
      week = week.map((dt) => {
        return that.dateFormat(dt)
      })
      return week.includes(val)
    },
    dateFormat (dt) {
      const [year, month, day] = dt.toLocaleDateString().split('/')
      const monthStr = ('0' + month).slice(-2)
      const dayStr = ('0' + day).slice(-2)
      return `${year}-${monthStr}-${dayStr}`
    }
  },
  mounted () {
    // 再編集のときの初期値を設定
    if (this.editInitialValue) {
      const time = new Date(this.editInitialValue.study_time)
      const hour = time.getHours()
      const minute = time.getMinutes()
      this.hour = hour.toString()
      this.minute = minute.toString()
      this.memo = this.editInitialValue.memo
      const studyDate = new Date(this.editInitialValue.study_date)
      this.studyDate = this.dateFormat(studyDate)
      this.tags = this.tagsProcessing
    } else {
      this.hour = '0'
      this.minute = '1'
    }
  }
}
</script>

<style>
#datePicker {
  position: absolute;
  top: 70px;
  left: 20px;
  z-index: 10001;
  border: 1px solid #ddd;
  border-radius: 3px;
  box-shadow: 0 0 8px 0 rgba(0,0,0,0.15);
}

@media (max-width: 480px) {
  .headline {
    font-size: 1.2em !important;
    padding-bottom: 0 !important;
  }

  .time-report-form-card-text {
    padding: 0 !important;
  }

  .study-date-title {
    margin-left: 10px;
  }
}
</style>
