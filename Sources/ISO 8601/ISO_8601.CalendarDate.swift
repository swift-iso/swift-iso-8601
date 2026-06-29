//
//  ISO_8601.CalendarDate.swift
//  swift-iso-8601
//
//  Namespace for the ISO 8601 calendar-date grammar (YYYY-MM-DD / YYYYMMDD).
//
//  A calendar date has no standalone domain value — its value is ISO_8601.DateTime —
//  so CalendarDate is a namespace that hosts the sub-grammar leaf parser
//  `CalendarDate.Parse`, mirroring the subject-first shape of WeekDate.Parse and
//  OrdinalDate.Parse.
//

extension ISO_8601 {
    /// Namespace for the ISO 8601 calendar-date grammar.
    public enum CalendarDate {}
}
