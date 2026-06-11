// Tour configuration constants — step boundaries and page mappings.

/// Steps at which transition popups should be shown (end of each screen's steps).
const kTransitionSteps = {2, 5, 7};

/// The final step of the tour where completion popup is shown.
const kFinalStep = 10;

/// Page names for the page selector popup.
const kTourPageNames = ['Trang chủ', 'Thư giãn', 'Phân tích cảm xúc', 'Cài đặt'];

/// Maps a page index (0–3) to the first tour step on that page.
/// Used when restarting the tour at a specific page.
int startStepForPage(int pageIndex) {
  switch (pageIndex) {
    case 0:
      return 0;
    case 1:
      return 3;
    case 2:
      return 6;
    case 3:
      return 8;
    default:
      return 0;
  }
}
