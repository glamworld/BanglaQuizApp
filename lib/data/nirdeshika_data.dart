import 'package:bangla_gk_quiz/model/nirdeshika.dart';

class NirdeshikaData{
  List<Nirdeshika> _nirdeshikaData = [
    Nirdeshika(suggesion: 'আপনাকে প্রতি লেভেলে একটি করে প্রশ্ন করা হবে সাথে থাকবে চারটি অপশন।'),
    Nirdeshika(suggesion: 'প্রশ্ন দেখার পর উত্তর করার জন্য আপনি ৩০ সেকেন্ড পাবেন।'),
    Nirdeshika(suggesion: 'আপনার দেওয়া উত্তর ঠিক থাকলে আপনি প্রতি লেভেলে একটা নির্দিষ্ট পরিমাণের টাকা জিতবেন।'),
    Nirdeshika(suggesion: 'আপনি যদি নিজ ইচ্ছায় খেলা বন্ধ করেন সেক্ষেত্রে আপনি যত টাকা জিতেছেন তা আপনি পাবেন।'),
    Nirdeshika(suggesion: '৫০ঃ৫০, এটি নির্বাচন করলে একটি প্রশ্নের চারটি অপশন থেকে ভুল দুটি অপশন চলে যাবে।'),
    Nirdeshika(suggesion: 'দর্শক ভোট নির্বাচন করলে একটি গ্রাফিক্যাল ভিউ দেখাবে।'),
    Nirdeshika(suggesion: 'তাহলে গেমটি উপভোগ করুন।'),
  ];

  int _suggessionNo =0;
  String getNirdeshika() {
    return _nirdeshikaData[_suggessionNo].suggesion;
  }

  void nextNirdeshika(int choiceNumber) {
    if (choiceNumber == 1 && _suggessionNo == 0) {
      _suggessionNo = 1;
    } else if (choiceNumber == 1 && _suggessionNo == 1) {
      _suggessionNo = 2;
    } else if (choiceNumber == 1 && _suggessionNo == 2) {
      _suggessionNo = 3;
    } else if (choiceNumber == 1 && _suggessionNo == 3) {
      _suggessionNo = 4;
    } else if (choiceNumber == 1 && _suggessionNo == 4) {
      _suggessionNo = 5;
    } else if (choiceNumber == 1 && _suggessionNo == 5) {
      _suggessionNo = 6;
    } else if (choiceNumber == 2 && _suggessionNo == 1) {
      _suggessionNo = 0;
    }else if (choiceNumber == 2 && _suggessionNo == 2) {
      _suggessionNo = 1;
    } else if (choiceNumber == 2 && _suggessionNo == 3) {
      _suggessionNo = 2;
    } else if (choiceNumber == 2 && _suggessionNo == 4) {
      _suggessionNo = 3;
    } else if (choiceNumber == 2 && _suggessionNo == 5) {
      _suggessionNo = 4;
    } else if (choiceNumber == 2 && _suggessionNo == 6) {
      _suggessionNo = 5;
    }
  }
  bool PreviousButtonShouldNotBeVisible() {
    if (_suggessionNo == 0) {
      return false;
    } else {
      return true;
    }
  }
  bool NextButtonShouldNotBeVisible() {
    if (_suggessionNo == 6) {
      return false;
    } else {
      return true;
    }
  }
}