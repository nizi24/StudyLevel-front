<template>
  <ValidationObserver ef="obs" v-slot="{ passes }">
    <v-row>
      <v-card class="mx-auto mt-5 pa-5" width="500px">
        <v-card-title>
          <h1 class="login-title">ログイン</h1>
        </v-card-title>
        <v-card-text>
          <v-form>
            <VTextFieldWithValidation
            v-model="email"
            rules="max:255|required|email"
            label="メールアドレス"
            />
            <VTextFieldWithValidation
            v-model="password"
            rules="required|min:6"
            label="パスワード"
            :type="show1 ? 'text' : 'password'"
            :append-icon="show1 ? 'mdi-eye' : 'mdi-eye-off'"
            @click:append="show1 = !show1"
            vid="password"
            />
            <v-row justify="center">
              <v-btn
              color="primary"
              class="mx-auto login-btn"
              @click="passes(login)"
              >ログイン</v-btn>
            </v-row>
            <p v-if="error" class="errors">{{error}}</p>
          </v-form>
        </v-card-text>
      </v-card>
    </v-row>
  </ValidationObserver>
</template>

<script>
import { setUser } from '../plugins/auth-check.js'
import VTextFieldWithValidation from '~/components/molecules/inputs/VTextFieldWithValidation.vue'
import firebase from '@/plugins/firebase'
export default {
  components: {
    VTextFieldWithValidation
  },
  data () {
    return {
      email: '',
      password: '',
      show1: false,
      error: ''
    }
  },
  methods: {
    login () {
      firebase
        .auth()
        .signInWithEmailAndPassword(this.email, this.password)
        .then((res) => {
          setUser(res.user, this.$store)
          this.$store.commit('drawing/setFlash', {
            status: true,
            type: 'success',
            message: 'ログインしました'
          })
          setTimeout(() => {
            this.$store.commit('drawing/setFlash', {})
          }, 2000)
          setTimeout(() => {
            this.$router.push('/')
          }, 200)
        })
        .catch((error) => {
          this.error = ((code) => {
            switch (code) {
              case 'auth/user-not-found':
                return 'メールアドレスが間違っています'
              case 'auth/wrong-password':
                return '※パスワードが正しくありません'
              default:
                return '※メールアドレスとパスワードをご確認ください'
            }
          })(error.code)
        })
    }
  },
  fetch ({ redirect, store }) {
    if (store.state.currentUser) {
      return redirect('/')
    }
  },
  head () {
    return {
      title: 'ログイン - PolPa'
    }
  }
}

</script>

<style scoped>
.login-title {
  font-weight: normal;
  font-size: 1.4em;
}

.login-btn {
  margin-top: 10px;
}

.errors {
  color: red;
  margin-top: 20px;
}
</style>
