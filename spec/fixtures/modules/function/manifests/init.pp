class function {
  $message = test_function()
  notify { "test_function":
    message => $message
  }
}
