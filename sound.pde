import ddf.minim.*;
SoundManager soundManager;

class SoundManager {
    Minim minim;
    HashMap<String, AudioSample> soundMap;
    AudioPlayer bgmPlayer; // 用于背景音乐的 AudioPlayer
    boolean muted = false;

    SoundManager(PApplet parent) {
        minim = new Minim(parent);
        soundMap = new HashMap<String, AudioSample>();
    }

    // 加载音效文件（短音效）
    void loadSound(String name, String fileName) {
        AudioSample sound = minim.loadSample(fileName, 512);
        soundMap.put(name, sound);
    }

    // 加载背景音乐
    void loadBGM(String fileName) {
        bgmPlayer = minim.loadFile(fileName);
        bgmPlayer.loop(); // 设置为循环播放
    }

    // 播放音效，使用默认音量
    void playSound(String name) {
        playSound(name, 1.0f); // 默认音量为 1.0f（100%）
    }

    // 播放音效，指定音量（0.0f 到 1.0f）
    void playSound(String name, float volume) {
        if (muted) return; // 如果静音，直接返回

        AudioSample sound = soundMap.get(name);
        if (sound != null) {
            sound.setGain(linearToDecibels(volume));
            sound.trigger(); // 使用 trigger() 方法播放音效
        } else {
            println("Sound " + name + " not found!");
        }
    }

    // 开始播放背景音乐
    void playBGM() {
        if (bgmPlayer != null) {
            bgmPlayer.loop();
            if (muted) {
                bgmPlayer.mute();
            } else {
                bgmPlayer.unmute();
            }
        }
    }

    // 暂停背景音乐
    void pauseBGM() {
        if (bgmPlayer != null) {
            bgmPlayer.pause();
        }
    }

    // 停止背景音乐
    void stopBGM() {
        if (bgmPlayer != null) {
            bgmPlayer.pause();
            bgmPlayer.rewind();
        }
    }

    // 设置背景音乐音量
    void setBGMVolume(float volume) {
        if (bgmPlayer != null) {
            bgmPlayer.setGain(linearToDecibels(volume));
        }
    }

    // 切换静音状态
    void toggleMute() {
        muted = !muted;
        // 当静音时，停止所有正在播放的音效，并静音背景音乐
        if (muted) {
            // 停止所有音效
            for (AudioSample sound : soundMap.values()) {
                sound.stop();
            }
            // 静音背景音乐
            if (bgmPlayer != null) {
                bgmPlayer.mute();
            }
        } else {
            // 取消静音背景音乐
            if (bgmPlayer != null) {
                bgmPlayer.unmute();
            }
        }
    }

    // 设置音效音量
    void setVolume(String name, float volume) {
        AudioSample sound = soundMap.get(name);
        if (sound != null) {
            sound.setGain(linearToDecibels(volume));
        }
    }

    // 将线性音量转换为分贝
    float linearToDecibels(float volume) {
        if (volume <= 0) {
            return -80.0f; // 设定为 -80 分贝，相当于静音
        }
        return 20 * (float) Math.log10(volume);
    }

    // 在程序结束时关闭 Minim
    void close() {
        if (bgmPlayer != null) {
            bgmPlayer.close();
        }
        minim.stop();
    }
}
