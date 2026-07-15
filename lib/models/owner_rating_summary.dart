class OwnerRatingSummary {
  const OwnerRatingSummary({
    this.averageRating = 0,
    this.ratingsCount = 0,
    this.currentUserRating,
  });

  final double averageRating;
  final int ratingsCount;
  final int? currentUserRating;

  bool get hasRatings => ratingsCount > 0;

  OwnerRatingSummary copyWith({
    double? averageRating,
    int? ratingsCount,
    int? currentUserRating,
    bool clearCurrentUserRating = false,
  }) {
    return OwnerRatingSummary(
      averageRating: averageRating ?? this.averageRating,
      ratingsCount: ratingsCount ?? this.ratingsCount,
      currentUserRating: clearCurrentUserRating
          ? null
          : currentUserRating ?? this.currentUserRating,
    );
  }
}
