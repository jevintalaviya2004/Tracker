export type TaskLink = { label: string; url: string };

export type Task = {
  id: string;
  title: string;
  xp: number;
  weekdays: number[];
  sort_order: number;
  created_at: string;
  archived_at: string | null;
  /** Set for one-off plan tasks: only scheduled on this date (YYYY-MM-DD) */
  day: string | null;
  details: string | null;
  links: TaskLink[] | null;
};

export type Completion = {
  task_id: string;
  day: string; // YYYY-MM-DD
  xp: number;
};

export type DayBonus = {
  day: string;
  xp: number;
};

export type Milestone = {
  id: string;
  phase: string;
  phase_title: string;
  title: string;
  sort_order: number;
  done_at: string | null;
};

export type LevelInfo = {
  level: number;
  xpIntoLevel: number;
  xpForNext: number;
};

export type TodayTask = {
  id: string;
  title: string;
  xp: number;
  done: boolean;
  details: string | null;
  links: TaskLink[];
  planned: boolean;
};

export type PlanItem = {
  id: string;
  day: string;
  title: string;
  xp: number;
  details: string | null;
  links: TaskLink[];
  done: boolean;
};

export type PlanResponse = {
  today: string;
  items: PlanItem[];
};

export type HeatCell = {
  day: string;
  scheduled: number;
  done: number;
  future: boolean;
};

export type WeekXp = {
  weekStart: string;
  xp: number;
};

export type Achievement = {
  id: string;
  icon: string;
  title: string;
  description: string;
  unlocked: boolean;
};

export type PhaseView = {
  phase: string;
  title: string;
  done: number;
  total: number;
  milestones: Milestone[];
};

export type AppState = {
  today: string;
  weekday: number;
  todayTasks: TodayTask[];
  totalXp: number;
  xpToday: number;
  level: LevelInfo;
  streak: number;
  bestStreak: number;
  dayComplete: boolean;
  phases: PhaseView[];
  heatmap: HeatCell[];
  weeklyXp: WeekXp[];
  achievements: Achievement[];
};
