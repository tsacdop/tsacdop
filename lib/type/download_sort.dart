// Keep these indices stable: storage management also uses the first three.
enum DownloadSort {
  newest,
  oldest,
  size,
  title,
  podcast;

  static DownloadSort fromIndex(int? index) =>
      index != null && index >= 0 && index < values.length
      ? values[index]
      : newest;
}
