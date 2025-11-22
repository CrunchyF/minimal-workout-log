import Foundation
import SwiftData

enum AuthMode: String, Codable, CaseIterable, Identifiable {
    case iCloudUser
    case localOnly
    var id: String { rawValue }
}

enum WeightUnit: String, Codable, CaseIterable, Identifiable {
    case kg
    case lb
    var id: String { rawValue }
}

enum ExerciseOrigin: String, Codable, CaseIterable, Identifiable {
    case fromTemplate
    case squeezedIn
    case swappedIn
    var id: String { rawValue }
}

enum SessionMood: String, Codable, CaseIterable, Identifiable {
    case good
    case neutral
    case hard
    var id: String { rawValue }
}

@Model
final class UserSettings {
    @Attribute(.unique) var id: UUID
    var authMode: AuthMode
    var weightUnit: WeightUnit
    var createdAt: Date
    var updatedAt: Date

    init(id: UUID = UUID(), authMode: AuthMode = .iCloudUser, weightUnit: WeightUnit = .kg, createdAt: Date = .now, updatedAt: Date = .now) {
        self.id = id
        self.authMode = authMode
        self.weightUnit = weightUnit
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

@Model
final class WorkoutTemplate {
    @Attribute(.unique) var id: UUID
    var name: String
    @Relationship(deleteRule: .cascade) var exercises: [TemplateExercise]
    var createdAt: Date
    var updatedAt: Date
    var isArchived: Bool

    init(id: UUID = UUID(), name: String, exercises: [TemplateExercise] = [], createdAt: Date = .now, updatedAt: Date = .now, isArchived: Bool = false) {
        self.id = id
        self.name = name
        self.exercises = exercises
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isArchived = isArchived
    }
}

@Model
final class TemplateExercise {
    @Attribute(.unique) var id: UUID
    var name: String
    var orderIndex: Int
    var plannedSets: Int
    var repRangeMin: Int?
    var repRangeMax: Int?
    var parentTemplate: WorkoutTemplate?

    init(id: UUID = UUID(), name: String, orderIndex: Int, plannedSets: Int, repRangeMin: Int? = nil, repRangeMax: Int? = nil, parentTemplate: WorkoutTemplate? = nil) {
        self.id = id
        self.name = name
        self.orderIndex = orderIndex
        self.plannedSets = plannedSets
        self.repRangeMin = repRangeMin
        self.repRangeMax = repRangeMax
        self.parentTemplate = parentTemplate
    }
}

@Model
final class WorkoutSession {
    @Attribute(.unique) var id: UUID
    var date: Date
    var startTime: Date
    var endTime: Date?
    var template: WorkoutTemplate?
    @Relationship(deleteRule: .cascade) var exercises: [ExerciseSession]
    var totalWorkTimeSeconds: Int
    var totalRestTimeSeconds: Int
    var totalWeightLifted: Double
    var totalSets: Int
    var mood: SessionMood?
    var notesSummary: String?

    init(id: UUID = UUID(), date: Date = .now, startTime: Date = .now, endTime: Date? = nil, template: WorkoutTemplate? = nil, exercises: [ExerciseSession] = [], totalWorkTimeSeconds: Int = 0, totalRestTimeSeconds: Int = 0, totalWeightLifted: Double = 0, totalSets: Int = 0, mood: SessionMood? = nil, notesSummary: String? = nil) {
        self.id = id
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.template = template
        self.exercises = exercises
        self.totalWorkTimeSeconds = totalWorkTimeSeconds
        self.totalRestTimeSeconds = totalRestTimeSeconds
        self.totalWeightLifted = totalWeightLifted
        self.totalSets = totalSets
        self.mood = mood
        self.notesSummary = notesSummary
    }
}

@Model
final class ExerciseSession {
    @Attribute(.unique) var id: UUID
    var workout: WorkoutSession?
    var templateExercise: TemplateExercise?
    var name: String
    var orderIndex: Int
    var origin: ExerciseOrigin
    @Relationship(deleteRule: .cascade) var sets: [WorkoutSet]
    var notes: String?

    init(id: UUID = UUID(), workout: WorkoutSession? = nil, templateExercise: TemplateExercise? = nil, name: String, orderIndex: Int, origin: ExerciseOrigin = .fromTemplate, sets: [WorkoutSet] = [], notes: String? = nil) {
        self.id = id
        self.workout = workout
        self.templateExercise = templateExercise
        self.name = name
        self.orderIndex = orderIndex
        self.origin = origin
        self.sets = sets
        self.notes = notes
    }
}

@Model
final class WorkoutSet {
    @Attribute(.unique) var id: UUID
    var exerciseSession: ExerciseSession?
    var setIndex: Int
    var reps: Int
    var weight: Double
    var completedAt: Date
    var isExtra: Bool
    var isPR: Bool

    init(id: UUID = UUID(), exerciseSession: ExerciseSession? = nil, setIndex: Int, reps: Int, weight: Double, completedAt: Date = .now, isExtra: Bool = false, isPR: Bool = false) {
        self.id = id
        self.exerciseSession = exerciseSession
        self.setIndex = setIndex
        self.reps = reps
        self.weight = weight
        self.completedAt = completedAt
        self.isExtra = isExtra
        self.isPR = isPR
    }
}
