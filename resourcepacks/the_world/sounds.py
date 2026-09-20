import os, json, contextlib, wave, time
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

try:
    from mutagen import File as MutagenFile
except ModuleNotFoundError:
    MutagenFile = None

TICKS_PER_SEC = 20

def get_sound_length(path: str) -> int:
    if MutagenFile is not None:
        try:
            audio = MutagenFile(path)
            if audio is not None and audio.info.length:
                return round(audio.info.length * TICKS_PER_SEC)
        except Exception as e:
            print(f"[Mutagen] {e}")
    try:
        with contextlib.closing(wave.open(path, "rb")) as f:
            seconds = f.getnframes() / f.getframerate()
            return round(seconds * TICKS_PER_SEC)
    except Exception as e:
        print(f"[wave] {e}")
    return 0

def process_namespace_sounds(namespace_path, namespace):
    sounds, lengths = {}, {}
    root_sounds = os.path.join(namespace_path, "sounds")

    for root, _, files in os.walk(root_sounds):
        rel_path = os.path.relpath(root, root_sounds)
        dot_key = rel_path.replace(os.sep, ".")

        numbered = [f for f in files if f.endswith(".ogg") and f[:-4].isdigit()]
        others = [f for f in files if f.endswith(".ogg") and not f[:-4].isdigit()]

        if numbered and not others:
            entry_list, entry_lengths = [], []
            for f in sorted(numbered, key=lambda n: int(n[:-4])):
                stem = f[:-4]
                file_path = os.path.join(root, f)
                sound_id = f"{namespace}:{rel_path}/{stem}"

                entry = {"name": sound_id}
                entry_list.append(entry)
                l = get_sound_length(file_path)
                entry_lengths.append(l)

                indiv_key = f"{dot_key}.{stem}"
                sounds[indiv_key] = {"replace": True, "sounds": [entry]}
                lengths[indiv_key] = l

            sounds[dot_key] = {"replace": True, "sounds": entry_list}
            lengths[dot_key] = round(sum(entry_lengths) / len(entry_lengths))
        else:
            for f in others:
                stem = f[:-4]
                file_path = os.path.join(root, f)
                sound_id = f"{namespace}:{rel_path}/{stem}"
                key = f"{dot_key}.{stem}" if rel_path != "." else stem

                entry = {"name": sound_id}
                txt_path = os.path.join(root, f"{stem}.txt")
                if os.path.isfile(txt_path):
                    try:
                        with open(txt_path, "r", encoding="utf-8") as txt_file:
                            subtitle_line = txt_file.readline().strip()
                            if subtitle_line:
                                entry["subtitle"] = subtitle_line
                    except Exception as e:
                        print(f"[subtitle] Error reading {txt_path}: {e}")

                sounds[key] = {"replace": True, "sounds": [entry], "preload": True}
                lengths[key] = get_sound_length(file_path)

    return sounds, lengths

def regenerate_namespace(base_path, namespace):
    namespace_path = os.path.join(base_path, namespace)
    sounds, lengths = process_namespace_sounds(namespace_path, namespace)

    with open(os.path.join(namespace_path, "sounds.json"), "w", encoding="utf-8") as f:
        json.dump(sounds, f, indent=2)
    with open(os.path.join(namespace_path, "sound_lengths.txt"), "w", encoding="utf-8") as f:
        for key in sorted(lengths):
            f.write(f"{key}: {lengths[key]} ticks\n")

    print(f"✓ Updated {namespace}/sounds.json and sound_lengths.txt")

class SoundsHandler(FileSystemEventHandler):
    def __init__(self, base_path, namespace):
        self.base_path = base_path
        self.namespace = namespace

    def on_any_event(self, event):
        if event.is_directory:
            return
        if event.src_path.endswith((".ogg", ".txt")):
            regenerate_namespace(self.base_path, self.namespace)

if __name__ == "__main__":
    here = os.path.dirname(os.path.abspath(__file__))
    here = os.path.join(here,"assets")

    observer = Observer()
    for entry in os.listdir(here):
        if entry == "minecraft":
            continue

        namespace_path = os.path.join(here, entry)
        sounds_dir = os.path.join(namespace_path, "sounds")
        if os.path.isdir(sounds_dir):
            print(f"Watching namespace: {entry}")
            regenerate_namespace(here, entry)
            event_handler = SoundsHandler(here, entry)
            observer.schedule(event_handler, sounds_dir, recursive=True)

    observer.start()
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
    observer.join()