import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../themes/app_theme.dart';

class CalmScreen extends StatefulWidget {
  const CalmScreen({super.key});
  @override
  State<CalmScreen> createState() => _CalmScreenState();
}

class _CalmScreenState extends State<CalmScreen> {
  String _mood = '';

  final Map<String, List<Map<String, dynamic>>> _content = {
    'sad': [
      {'type':'quote','text':"It's okay to not be okay. Your pain is real and it deserves space. 🌧️"},
      {'type':'quote','text':"You are not broken. You are in the middle of your story. 📖"},
      {'type':'quote','text':"The wound is the place where the light enters you. — Rumi 🌟"},
      {'type':'music','title':'Peaceful Piano for Healing','url':'https://www.youtube.com/watch?v=77ZozI0rw7w'},
      {'type':'music','title':'Rain Sounds for Deep Calm','url':'https://www.youtube.com/watch?v=mPZkdNFkNps'},
      {'type':'story','title':'The Butterfly Struggle 🦋','text':'A man saw a butterfly fighting to escape its cocoon. He helped it out — but it could never fly. The struggle builds wings. Your pain is building yours.'},
      {'type':'youtube','title':'How to Feel Better When Sad','channel':'Therapy in a Nutshell','url':'https://www.youtube.com/watch?v=MSBs1TjfQLc'},
    ],
    'angry': [
      {'type':'quote','text':"Between stimulus and response, there is space. In that space is your power. — Viktor Frankl ⚡"},
      {'type':'quote','text':"Anger is a signal that a boundary was crossed. Honor the signal — not the reaction. 🛡️"},
      {'type':'music','title':'432Hz — Release Anger & Tension','url':'https://www.youtube.com/watch?v=etKCDIsNB48'},
      {'type':'music','title':'Deep Meditation for Anger Relief','url':'https://www.youtube.com/watch?v=odADwWzHR24'},
      {'type':'story','title':'The Hot Tea Story ☕','text':"When someone offends you, they are offering you hot tea. You can choose not to take it. Their anger belongs to them. Your peace belongs to you."},
      {'type':'youtube','title':'Anger Management Techniques','channel':'MedCircle','url':'https://www.youtube.com/watch?v=BsVq5R_F6RA'},
    ],
    'happy': [
      {'type':'quote','text':"Joy is the most infallible sign of the presence of God. — Teilhard de Chardin ✨"},
      {'type':'quote','text':"Happiness is not something ready made — it comes from your own actions. — Dalai Lama 💫"},
      {'type':'music','title':'Uplifting Morning Music','url':'https://www.youtube.com/watch?v=5qap5aO4i9A'},
      {'type':'music','title':'Happy Positive Vibes Mix','url':'https://www.youtube.com/watch?v=ZbZSe6N_BXs'},
      {'type':'story','title':'The Grateful Farmer 🌻','text':"A farmer found gold but used it to water his neighbor's dying crops. That year, both farms bloomed. Joy shared is joy multiplied."},
      {'type':'youtube','title':'The Science of Happiness','channel':'SciShow Psych','url':'https://www.youtube.com/watch?v=e9dZQelFews'},
    ],
    'lovely': [
      {'type':'quote','text':"Love is not something you find. Love is something that finds you. 💕"},
      {'type':'quote','text':"The best thing to hold onto in life is each other. — Audrey Hepburn 🌸"},
      {'type':'quote','text':"Where there is love, there is life. — Mahatma Gandhi ❤️"},
      {'type':'music','title':'Romantic Soft Piano Music','url':'https://www.youtube.com/watch?v=qlMpiwzjmYg'},
      {'type':'music','title':'Love & Peace Music — Healing Frequencies','url':'https://www.youtube.com/watch?v=1ZYbU82GVz4'},
      {'type':'story','title':'The Rose Garden 🌹','text':"A gardener asked why she spent so much time on roses when they fade. She smiled — the beauty is not in keeping them, but in the love you give while they bloom. Love freely. Love fully."},
      {'type':'youtube','title':'Acts of Love — TED Talk','channel':'TED','url':'https://www.youtube.com/watch?v=eLfXpRkVZaI'},
    ],
    'calm': [
      {'type':'quote','text':"Calm is a superpower. In the middle of chaos, be still. 🌊"},
      {'type':'quote','text':"Peace is not the absence of conflict. It is the ability to handle conflict by peaceful means. ☘️"},
      {'type':'music','title':'Calm Piano — Relaxing Music','url':'https://www.youtube.com/watch?v=lFcSrYw-ARY'},
      {'type':'music','title':'432Hz Deep Relaxation Music','url':'https://www.youtube.com/watch?v=etKCDIsNB48'},
      {'type':'story','title':'The Still Lake 🧘','text':'A student asked his teacher why the lake was so calm. The teacher replied — because it does not fight the wind. It simply lets the wind pass. Be the lake.'},
      {'type':'youtube','title':'5-Minute Guided Meditation for Calm','channel':'Great Meditation','url':'https://www.youtube.com/watch?v=inpok4MKVLM'},
    ],
    'normal': [
      {'type':'quote','text':"Ordinary days are the building blocks of an extraordinary life. 🧱"},
      {'type':'quote','text':"There is beauty in the mundane. Look closer. 👀"},
      {'type':'music','title':'Lo-fi Study Beats','url':'https://www.youtube.com/watch?v=5qap5aO4i9A'},
      {'type':'story','title':'The Ordinary Moment ☀️','text':"A philosopher once said that true happiness is not found in peak moments — but in the quiet in-between. Your normal day is someone else's dream."},
      {'type':'youtube','title':'The Power of Ordinary Days','channel':'Better Ideas','url':'https://www.youtube.com/watch?v=LO1mTELoj6o'},
    ],
    'joy': [
      {'type':'quote','text':"Joy is not in things; it is in us. — Richard Wagner 😄"},
      {'type':'quote','text':"Find joy in the ordinary. Celebrate everything. 🎉"},
      {'type':'music','title':'Feel-Good Happy Music','url':'https://www.youtube.com/watch?v=ZbZSe6N_BXs'},
      {'type':'story','title':'The Dancing Child 💃','text':"A child danced in a rainstorm. An adult ran inside. Later the adult asked why she danced. She said — because the rain is dancing too! Joy is permission you give yourself."},
      {'type':'youtube','title':'How to Feel More Joy Daily','channel':'Psych2Go','url':'https://www.youtube.com/watch?v=e9dZQelFews'},
    ],
    'crying': [
      {'type':'quote','text':"Tears are words the heart cannot express. Let them flow. 💙"},
      {'type':'quote','text':"Crying does not mean you are weak. It shows you have been strong for too long. 🌧️"},
      {'type':'music','title':'Healing Frequency — 528Hz','url':'https://www.youtube.com/watch?v=LVOqMDJNv0I'},
      {'type':'music','title':'Sad Piano Music for Emotional Release','url':'https://www.youtube.com/watch?v=77ZozI0rw7w'},
      {'type':'story','title':'The Ocean of Tears 🌊','text':"A wise woman told her granddaughter — every tear you cry waters the garden of your soul. Without rain, nothing blooms. Your tears are not weakness. They are rain for your becoming."},
      {'type':'youtube','title':'Why Crying is Good for You','channel':'Therapy in a Nutshell','url':'https://www.youtube.com/watch?v=MSBs1TjfQLc'},
    ],
    'blessing': [
      {'type':'quote','text':"Gratitude turns what we have into enough. 🌟"},
      {'type':'quote','text':"A blessed life is not about having everything — it is about appreciating everything you have. 🙏"},
      {'type':'music','title':'432Hz Miracle Tone — Gratitude Music','url':'https://www.youtube.com/watch?v=1ZYbU82GVz4'},
      {'type':'story','title':'The Lamp 💡','text':"A beggar found a small lamp. He lit it and shared it with strangers. By morning, his whole street was glowing. Those who share their blessings attract more. Count yours today."},
      {'type':'youtube','title':'Gratitude — Counting Your Blessings','channel':'TED-Ed','url':'https://www.youtube.com/watch?v=WPPPFqsECz0'},
    ],
    'neutral': [
      {'type':'quote','text':"It's okay to just exist today. Not every day needs a breakthrough. 🌿"},
      {'type':'quote','text':"Between one feeling and another lives a quiet space — stay in it for a while. ☀️"},
      {'type':'music','title':'Lo-fi Chill Study Music','url':'https://www.youtube.com/watch?v=5qap5aO4i9A'},
      {'type':'story','title':'The Empty Canvas 🎨','text':"A painter stared at a blank canvas for weeks. His student asked, why do you not paint? He replied: I am waiting for the painting to tell me what it wants to be. Sometimes neutral is the beginning of everything."},
    ],
    'grateful': [
      {'type':'quote','text':"When you are grateful, fear disappears and abundance appears. — Tony Robbins 🙏"},
      {'type':'quote','text':"Gratitude is the healthiest of all human emotions. — Zig Ziglar 💛"},
      {'type':'music','title':'Gratitude 528Hz — Positive Energy','url':'https://www.youtube.com/watch?v=1ZYbU82GVz4'},
      {'type':'story','title':'The Two Wolves 🐺','text':"A grandfather told his grandson: inside me two wolves fight — one of gratitude, one of complaint. The boy asked which wins. The grandfather said: the one I feed. Feed gratitude today."},
      {'type':'youtube','title':'The Power of Gratitude','channel':'TED-Ed','url':'https://www.youtube.com/watch?v=WPPPFqsECz0'},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Calm Space 🌿',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.bg, elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                AppColors.lavender.withValues(alpha: 0.2),
                AppColors.blue.withValues(alpha: 0.15),
              ]),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.lavender.withValues(alpha: 0.2))),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('This space is for you 💙',
                style: TextStyle(color: AppColors.textPrimary,
                  fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 6),
              Text("Whatever you're feeling is valid. Let's find some calm together.",
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5)),
            ]),
          ),
          const SizedBox(height: 24),
          const Text("How are you feeling right now?",
            style: TextStyle(color: AppColors.textPrimary,
              fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // Mood selector — tidy 2-row wrap (11 moods)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _moodBtn('happy',    '😊', 'Happy',    AppColors.primary),
              _moodBtn('grateful', '🙏', 'Grateful', AppColors.amber),
              _moodBtn('calm',     '😌', 'Calm',     const Color(0xFF64B5F6)),
              _moodBtn('joy',      '🥰', 'Joy',      const Color(0xFFFFB74D)),
              _moodBtn('blessing', '🙌', 'Blessing', const Color(0xFF81C784)),
              _moodBtn('normal',   '😶', 'Normal',   const Color(0xFF90A4AE)),
              _moodBtn('neutral',  '😐', 'Neutral',  AppColors.blue),
              _moodBtn('sad',      '😢', 'Sad',      AppColors.lavender),
              _moodBtn('crying',   '😭', 'Crying',   const Color(0xFF81D4FA)),
              _moodBtn('angry',    '😠', 'Angry',    const Color(0xFFEF6B6B)),
              _moodBtn('lovely',   '💕', 'Lovely',   const Color(0xFFE07AA0)),
            ],
          ),
          const SizedBox(height: 28),

          if (_mood.isEmpty)
            const Center(child: Column(children: [
              SizedBox(height: 30),
              Text('🌿', style: TextStyle(fontSize: 72)),
              SizedBox(height: 16),
              Text("I'm here whenever you're ready",
                style: TextStyle(color: AppColors.textSecondary)),
            ])),

          if (_mood.isNotEmpty) ..._buildContent(),
        ]),
      ),
    );
  }

  List<Widget> _buildContent() {
    final items = _content[_mood] ?? [];
    return [
      const Text('For you, right now 💫',
        style: TextStyle(color: AppColors.textPrimary,
          fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 16),
      ...items.map((item) {
        if (item['type'] == 'quote') {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.bgCardLight.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2))),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('❝', style: TextStyle(
                color: AppColors.primary.withValues(alpha: 0.7),
                fontSize: 24, height: 0.9)),
              const SizedBox(width: 10),
              Expanded(child: Text(item['text']!,
                style: const TextStyle(color: AppColors.textPrimary,
                  fontSize: 14, fontStyle: FontStyle.italic, height: 1.6))),
            ]),
          );
        } else if (item['type'] == 'music') {
          return GestureDetector(
            onTap: () => launchUrl(Uri.parse(item['url']!),
              mode: LaunchMode.externalApplication),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E).withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.deepPurple.withValues(alpha: 0.4))),
              child: Row(children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.music_note_rounded,
                    color: Color(0xFFBB86FC), size: 22)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['title']!, style: const TextStyle(
                      color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                    const Text('Tap to open on YouTube',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  ])),
                const Icon(Icons.open_in_new_rounded, color: Color(0xFFBB86FC), size: 16),
              ]),
            ),
          );
        } else if (item['type'] == 'youtube') {
          return GestureDetector(
            onTap: () => launchUrl(Uri.parse(item['url']!),
              mode: LaunchMode.externalApplication),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withValues(alpha: 0.25))),
              child: Row(children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.play_circle_filled_rounded,
                    color: Colors.redAccent, size: 26)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['title']!, style: const TextStyle(
                      color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                    if (item['channel'] != null)
                      Text(item['channel']!,
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  ])),
                const Icon(Icons.open_in_new_rounded, color: Colors.redAccent, size: 16),
              ]),
            ),
          );
        } else {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.bgCardLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Text('📖', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(item['title']!, style: const TextStyle(
                  color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
              ]),
              const SizedBox(height: 10),
              Text(item['text']!, style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 13, height: 1.6)),
            ]),
          );
        }
      }),
    ];
  }

  Widget _moodBtn(String mood, String emoji, String label, Color color) {
    final sel = _mood == mood;
    return GestureDetector(
      onTap: () => setState(() => _mood = mood),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: sel ? LinearGradient(colors: [
            color.withValues(alpha: 0.4), color.withValues(alpha: 0.2)]) : null,
          color: sel ? null : AppColors.bgCard.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: sel ? color : Colors.white.withValues(alpha: 0.08)),
          boxShadow: sel ? [BoxShadow(
            color: color.withValues(alpha: 0.25), blurRadius: 14, spreadRadius: 2)] : [],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(
            color: sel ? Colors.white : AppColors.textMuted,
            fontWeight: sel ? FontWeight.bold : FontWeight.normal, fontSize: 11)),
        ]),
      ),
    );
  }
}