String gvremakecode(String value) {
  if (value == "ABCD") {
    return "ABCD";
  }

  int i;
  int j;
  String Rtv = "";
  String RTVal = "";

  value = value.replaceAll(" ", "");

  for (i = 0; i < value.length;) {
    j = ACI_NO(value.substring(i, i + 1));
    Rtv = j.toString();

    i = i + 1;
    j = ACI_NO(value.substring(i, i + 1));
    Rtv = Rtv + j.toString();

    i = i + 1;
    j = ACI_NO(value.substring(i, i + 1));
    Rtv = Rtv + j.toString();

    j = int.parse(Rtv);
    RTVal = RTVal + String.fromCharCode(j);

    i = i + 1;
  }

  return RTVal;
}

int ACI_NO(String value) {
  int i;
  List<String> mch = [")", "~", "&", "!", "%", "^", "*", r'$', "#", "("];

  for (i = 0; i < 10; i++) {
    if (value == mch[i]) {
      break;
    }
  }

  return i;
}
