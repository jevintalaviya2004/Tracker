-- Track Record: 60-day plan (Thu 22 Oct to Sun 20 Dec 2026)
-- Run this in Supabase -> SQL Editor -> New query -> Run.
-- Safe to re-run: it updates plan tasks in place (by plan_key) and keeps your ticks.

-- 1) Columns for dated plan tasks
alter table public.tasks add column if not exists day date;
alter table public.tasks add column if not exists details text;
alter table public.tasks add column if not exists links jsonb not null default '[]'::jsonb;
alter table public.tasks add column if not exists plan_key text unique;
create index if not exists tasks_day_idx on public.tasks(day);

-- 2) Archive the 5 starter missions from seed.sql (the plan replaces them).
--    You can restore any of them in the Missions tab.
update public.tasks set archived_at = now()
where archived_at is null and day is null and title in (
  'Study / lecture review (45 min)',
  'Python or ML practice (1 problem)',
  'Work on portfolio project (30 min)',
  'Read one ML article or paper section',
  'Plan tomorrow (5 min)'
);

-- 3) Roadmap milestones matched to this plan
insert into public.milestones (id, phase, phase_title, title, sort_order) values
  ('p0-1', 'P0', 'Launch',      'Tracker live on phone, used 7 days in a row',                 1),
  ('p0-2', 'P0', 'Launch',      'GitHub profile README live with 4 pinned repos',              2),
  ('p0-3', 'P0', 'Launch',      'CV audit done (EN + DE)',                                     3),
  ('p1-1', 'P1', 'Foundations', 'Kaggle Intro to Machine Learning certificate',                4),
  ('p1-2', 'P1', 'Foundations', 'Kaggle Intermediate Machine Learning certificate',            5),
  ('p1-3', 'P1', 'Foundations', 'Explain bias/variance, CV, PR vs ROC, leakage without notes', 6),
  ('p1-4', 'P1', 'Foundations', 'Pass winter semester exams',                                  7),
  ('p2-1', 'P2', 'Build',       'Predictive maintenance model with MLflow tracking',           8),
  ('p2-2', 'P2', 'Build',       'FastAPI + Docker + CI, deployed live on Hugging Face',        9),
  ('p2-3', 'P2', 'Build',       'Monitoring report + README write-up + CV updated',           10),
  ('p2-4', 'P2', 'Build',       'Project 2: LLM / RAG application',                           11)
on conflict (id) do update set phase = excluded.phase, phase_title = excluded.phase_title,
  title = excluded.title, sort_order = excluded.sort_order;

-- 4) The plan
insert into public.tasks (plan_key, day, sort_order, title, xp, weekdays, details, links) values
  ($p$plan-2026-10-22-1$p$, '2026-10-22', 1, $p$Set up your learning workspace$p$, 30, '{0,1,2,3,4,5,6}', $p$Create one place where all plan work lives, so every later day starts quickly.
- Install uv (see the uv link) and check it with: uv --version
- Create a folder ml-notes, then run: uv init and uv add pandas scikit-learn matplotlib jupyter
- Start Jupyter with: uv run jupyter lab, make a notebook 00-setup.ipynb and run: import sklearn; print(sklearn.__version__)
- Create a public GitHub repo ml-notes and push the folder.
Done when: the notebook runs and ml-notes is on GitHub.$p$, $p$[{"label": "uv docs: Getting started", "url": "https://docs.astral.sh/uv/getting-started/"}]$p$::jsonb),
  ($p$plan-2026-10-22-2$p$, '2026-10-22', 2, $p$German: Easy German + shadowing (10–15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$- Pick one Easy German video of 10 minutes or less (street interviews are ideal) and watch it with German subtitles.
- Choose 3 sentences you like. Pause, repeat each one out loud 3 times and copy the rhythm (shadowing).
- Write the 3 sentences in your notebook.
Done when: you have said 3 sentences out loud and written them down.$p$, $p$[{"label": "Easy German on YouTube", "url": "https://youtube.com/easygerman"}]$p$::jsonb),
  ($p$plan-2026-10-23-1$p$, '2026-10-23', 1, $p$Git refresh, part 1$p$, 30, '{0,1,2,3,4,5,6}', $p$Git is used in every MLOps step later, so it has to feel automatic.
- Watch the first ~35 minutes of the Git crash course at 1.25x.
- In ml-notes, practise along: create a branch notes-week1, add a file git-cheatsheet.md, commit, push, open a pull request on GitHub and merge it.
- In git-cheatsheet.md, write the 10 commands you used, each with a one-line explanation.
Done when: the pull request is merged and the cheat sheet is on GitHub.$p$, $p$[{"label": "freeCodeCamp: Git and GitHub for Beginners", "url": "https://www.youtube.com/watch?v=RGOj5yH7evk"}]$p$::jsonb),
  ($p$plan-2026-10-23-2$p$, '2026-10-23', 2, $p$German: Nicos Weg B1 (10–15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$Keep working through the B1 film, a little each time.
- Open the film and continue from the timestamp you wrote down last time (first time: start at 0:00).
- Watch about 10 minutes with German subtitles on. Pause whenever you don't understand a sentence.
- In your German notebook, write 5 new words or phrases with one example sentence each.
- Write today's stop timestamp at the bottom of the page.
Done when: 5 new words are in your notebook and the timestamp is noted.$p$, $p$[{"label": "DW: Nicos Weg B1, full film with subtitles", "url": "https://www.youtube.com/watch?v=LkufozluseI"}, {"label": "DW: Nicos Weg B1, Folge 1 (2 min)", "url": "https://www.youtube.com/watch?v=o1zJ-BNQrU0"}]$p$::jsonb),
  ($p$plan-2026-10-24-1$p$, '2026-10-24', 1, $p$Build your GitHub profile README (60 min)$p$, 40, '{0,1,2,3,4,5,6}', $p$Recruiters often open your GitHub before your CV. Make the first screen say who you are.
- Create a repo named exactly like your GitHub username. It becomes your profile README (see the GitHub Docs link).
- Write 4 short blocks: who you are (AI student at THD, 5th semester), what you're looking for (Werkstudent / Pflichtpraktikum in ML engineering or MLOps), your skills (only the ones you can explain in an interview) and what you're building right now (this plan's predictive-maintenance project, marked "in progress").
- Pin your 4 best repos. Each one needs a README with what it does, why, how to run it and one result.
Done when: your profile page shows the README and 4 pinned repos with READMEs.$p$, $p$[{"label": "GitHub Docs: Managing your profile README", "url": "https://docs.github.com/en/account-and-profile/setting-up-and-managing-your-github-profile/customizing-your-profile/managing-your-profile-readme"}]$p$::jsonb),
  ($p$plan-2026-10-24-2$p$, '2026-10-24', 2, $p$CV audit (45 min)$p$, 30, '{0,1,2,3,4,5,6}', $p$Find the weak spots in your CV before an interviewer does.
- Print your CV or open it next to a blank page.
- For every project and skill, write one sentence about what YOU personally built or did. Be specific: "I built the text-to-speech component", not "we built a chatbot".
- Mark with a ? anything you couldn't explain for 2 minutes in an interview. Either remove it or plan to learn it (most of it is covered in this plan).
- List 3 numbers you can add (accuracy, R², users, time saved).
Done when: you have a marked-up CV and a list of fixes. You'll apply the fixes in week 8.$p$, $p$[]$p$::jsonb),
  ($p$plan-2026-10-24-3$p$, '2026-10-24', 3, $p$German: write about your week (15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$- By hand, write 6–8 sentences in German: Was habe ich diese Woche gelernt? Was war schwierig? Was mache ich nächste Woche?
- Use Perfekt for the past (ich habe … gelernt) and at least one weil-Satz.
- Check it with a translator and correct mistakes in a different colour.
Done when: the corrected text is in your notebook.$p$, $p$[]$p$::jsonb),
  ($p$plan-2026-10-25-1$p$, '2026-10-25', 1, $p$Git refresh, part 2 + tidy one old project (60 min)$p$, 40, '{0,1,2,3,4,5,6}', $p$- Watch the rest of the Git crash course at 1.5x. Skip the parts you already know.
- Pick one old project (for example your regression model project) and make it presentable:
- add a requirements.txt or pyproject.toml
- add a README with the problem, the data, the model and the before/after metric
- make sure it runs from a fresh clone, then push
Done when: the project runs from a fresh clone by following its README.$p$, $p$[{"label": "freeCodeCamp: Git and GitHub for Beginners", "url": "https://www.youtube.com/watch?v=RGOj5yH7evk"}]$p$::jsonb),
  ($p$plan-2026-10-25-2$p$, '2026-10-25', 2, $p$Plan your week around shifts (20 min)$p$, 20, '{0,1,2,3,4,5,6}', $p$The plan only works if the 45-minute slots actually exist.
- Open the Plan tab and read next week's tasks.
- Put each day's 45-minute slot into your phone calendar around your bakery shifts and lectures. Pick the same time each day if you can.
- Turn on the evening reminder on the Today tab, if you haven't yet.
Done when: next week's 5 weekday slots and 2 weekend slots are in your calendar.$p$, $p$[]$p$::jsonb),
  ($p$plan-2026-10-25-3$p$, '2026-10-25', 3, $p$German: podcast + vocab review (15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$- Listen to about 15 minutes of an Easy German Podcast episode (walk, cook or commute while listening).
- Then read through this week's vocabulary pages once and mark the 5 words you keep forgetting.
Done when: one episode chunk is done and 5 words are marked for next week.$p$, $p$[{"label": "Easy German Podcast", "url": "https://www.easygerman.org/podcast"}]$p$::jsonb),
  ($p$plan-2026-10-26-1$p$, '2026-10-26', 1, $p$Bias, variance and cross-validation$p$, 30, '{0,1,2,3,4,5,6}', $p$These two ideas explain almost every "why is my model bad?" question.
- Watch both StatQuest videos (about 12 minutes total).
- Write one page of handwritten notes: what bias means, what variance means, what overfitting looks like, and why k-fold CV is better than a single split.
- In a new notebook 01-evaluation.ipynb: load sklearn's load_breast_cancer, train LogisticRegression(max_iter=5000) and print cross_val_score(..., cv=5) with its mean and standard deviation.
Done when: you have the notes page plus a notebook printing 5 CV scores.$p$, $p$[{"label": "StatQuest: Bias and Variance (6 min)", "url": "https://www.youtube.com/watch?v=EuBBz3bI-aA"}, {"label": "StatQuest: Cross Validation (6 min)", "url": "https://www.youtube.com/watch?v=fSytzGwwBVw"}]$p$::jsonb),
  ($p$plan-2026-10-26-2$p$, '2026-10-26', 2, $p$German: Nicos Weg B1 (10–15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$Keep working through the B1 film, a little each time.
- Open the film and continue from the timestamp you wrote down last time (first time: start at 0:00).
- Watch about 10 minutes with German subtitles on. Pause whenever you don't understand a sentence.
- In your German notebook, write 5 new words or phrases with one example sentence each.
- Write today's stop timestamp at the bottom of the page.
Done when: 5 new words are in your notebook and the timestamp is noted.$p$, $p$[{"label": "DW: Nicos Weg B1, full film with subtitles", "url": "https://www.youtube.com/watch?v=LkufozluseI"}, {"label": "DW: Nicos Weg B1, Folge 1 (2 min)", "url": "https://www.youtube.com/watch?v=o1zJ-BNQrU0"}]$p$::jsonb),
  ($p$plan-2026-10-27-1$p$, '2026-10-27', 1, $p$Kaggle Intro to ML: lessons 1–3$p$, 30, '{0,1,2,3,4,5,6}', $p$Kaggle Learn is free and gives you a certificate you can add to LinkedIn.
- Sign in to Kaggle and start "Intro to Machine Learning".
- Do the lessons "How Models Work", "Basic Data Exploration" and "Your First Machine Learning Model", including the exercises (they run in the browser).
Done when: lesson 3's exercise shows all checks green.$p$, $p$[{"label": "Kaggle Learn: Intro to Machine Learning", "url": "https://www.kaggle.com/learn/intro-to-machine-learning"}]$p$::jsonb),
  ($p$plan-2026-10-27-2$p$, '2026-10-27', 2, $p$German: Easy German + shadowing (10–15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$- Pick one Easy German video of 10 minutes or less (street interviews are ideal) and watch it with German subtitles.
- Choose 3 sentences you like. Pause, repeat each one out loud 3 times and copy the rhythm (shadowing).
- Write the 3 sentences in your notebook.
Done when: you have said 3 sentences out loud and written them down.$p$, $p$[{"label": "Easy German on YouTube", "url": "https://youtube.com/easygerman"}]$p$::jsonb),
  ($p$plan-2026-10-28-1$p$, '2026-10-28', 1, $p$Kaggle Intro to ML: lessons 4–5$p$, 30, '{0,1,2,3,4,5,6}', $p$- Do "Model Validation" and "Underfitting and Overfitting" with their exercises.
- In your notes, write how the max_leaf_nodes experiment shows the bias–variance trade-off from Monday's video.
Done when: both exercises are complete and the note is written.$p$, $p$[{"label": "Kaggle Learn: Intro to Machine Learning", "url": "https://www.kaggle.com/learn/intro-to-machine-learning"}]$p$::jsonb),
  ($p$plan-2026-10-28-2$p$, '2026-10-28', 2, $p$German: Nicos Weg B1 (10–15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$Keep working through the B1 film, a little each time.
- Open the film and continue from the timestamp you wrote down last time (first time: start at 0:00).
- Watch about 10 minutes with German subtitles on. Pause whenever you don't understand a sentence.
- In your German notebook, write 5 new words or phrases with one example sentence each.
- Write today's stop timestamp at the bottom of the page.
Done when: 5 new words are in your notebook and the timestamp is noted.$p$, $p$[{"label": "DW: Nicos Weg B1, full film with subtitles", "url": "https://www.youtube.com/watch?v=LkufozluseI"}, {"label": "DW: Nicos Weg B1, Folge 1 (2 min)", "url": "https://www.youtube.com/watch?v=o1zJ-BNQrU0"}]$p$::jsonb),
  ($p$plan-2026-10-29-1$p$, '2026-10-29', 1, $p$Kaggle Intro to ML: finish + certificate$p$, 30, '{0,1,2,3,4,5,6}', $p$- Do "Random Forests" and "Machine Learning Competitions" (make the competition submission, even if the score is bad).
- Download the certificate and add it to LinkedIn under Licenses & certifications.
- In the Control tab, tick the milestone for the Kaggle Intro to ML certificate.
Done when: the certificate is on LinkedIn.$p$, $p$[{"label": "Kaggle Learn: Intro to Machine Learning", "url": "https://www.kaggle.com/learn/intro-to-machine-learning"}]$p$::jsonb),
  ($p$plan-2026-10-29-2$p$, '2026-10-29', 2, $p$German: Easy German + shadowing (10–15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$- Pick one Easy German video of 10 minutes or less (street interviews are ideal) and watch it with German subtitles.
- Choose 3 sentences you like. Pause, repeat each one out loud 3 times and copy the rhythm (shadowing).
- Write the 3 sentences in your notebook.
Done when: you have said 3 sentences out loud and written them down.$p$, $p$[{"label": "Easy German on YouTube", "url": "https://youtube.com/easygerman"}]$p$::jsonb),
  ($p$plan-2026-10-30-1$p$, '2026-10-30', 1, $p$Confusion matrix, sensitivity, specificity$p$, 30, '{0,1,2,3,4,5,6}', $p$- Watch both StatQuest videos.
- On paper, invent a test set: 100 machines, 10 really fail, and your model flags 15 of which 8 really fail. Draw the confusion matrix and compute accuracy, precision, recall (sensitivity) and specificity by hand.
- In 01-evaluation.ipynb, print confusion_matrix and classification_report for your breast-cancer model.
Done when: the paper calculation and the notebook output match the definitions.$p$, $p$[{"label": "StatQuest: The Confusion Matrix", "url": "https://www.youtube.com/watch?v=Kdsp6soqA7o"}, {"label": "StatQuest: Sensitivity and Specificity", "url": "https://www.youtube.com/watch?v=vP06aMoz4v8"}]$p$::jsonb),
  ($p$plan-2026-10-30-2$p$, '2026-10-30', 2, $p$German: Nicos Weg B1 (10–15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$Keep working through the B1 film, a little each time.
- Open the film and continue from the timestamp you wrote down last time (first time: start at 0:00).
- Watch about 10 minutes with German subtitles on. Pause whenever you don't understand a sentence.
- In your German notebook, write 5 new words or phrases with one example sentence each.
- Write today's stop timestamp at the bottom of the page.
Done when: 5 new words are in your notebook and the timestamp is noted.$p$, $p$[{"label": "DW: Nicos Weg B1, full film with subtitles", "url": "https://www.youtube.com/watch?v=LkufozluseI"}, {"label": "DW: Nicos Weg B1, Folge 1 (2 min)", "url": "https://www.youtube.com/watch?v=o1zJ-BNQrU0"}]$p$::jsonb),
  ($p$plan-2026-10-31-1$p$, '2026-10-31', 1, $p$ROC, AUC and thresholds (60 min)$p$, 40, '{0,1,2,3,4,5,6}', $p$- Watch StatQuest's Logistic Regression and ROC and AUC videos.
- In the notebook, use predict_proba to get probabilities, plot the ROC curve with RocCurveDisplay and print roc_auc_score.
- Try thresholds 0.3, 0.5 and 0.7. For each one, print precision and recall and write one sentence on what changes.
Done when: the notebook has the ROC curve, the AUC and a threshold table.$p$, $p$[{"label": "StatQuest: Logistic Regression", "url": "https://www.youtube.com/watch?v=yIYKR4sgzI8"}, {"label": "StatQuest: ROC and AUC", "url": "https://www.youtube.com/watch?v=4jRBRDbJemM"}]$p$::jsonb),
  ($p$plan-2026-10-31-2$p$, '2026-10-31', 2, $p$Precision–recall curves for imbalanced data (45 min)$p$, 30, '{0,1,2,3,4,5,6}', $p$Your project in week 4 has only about 3% failures, so this matters a lot.
- Read the scikit-learn Precision-Recall example (the binary part is enough).
- Add PrecisionRecallDisplay and average_precision_score to your notebook.
- In your notes, explain in your own words why ROC-AUC can look great on imbalanced data while PR-AUC shows the real problem.
Done when: the PR curve is in the notebook and the explanation is in your notes.$p$, $p$[{"label": "scikit-learn: Precision-Recall example", "url": "https://scikit-learn.org/stable/auto_examples/model_selection/plot_precision_recall.html"}]$p$::jsonb),
  ($p$plan-2026-10-31-3$p$, '2026-10-31', 3, $p$German: write about your week (15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$- By hand, write 6–8 sentences in German: Was habe ich diese Woche gelernt? Was war schwierig? Was mache ich nächste Woche?
- Use Perfekt for the past (ich habe … gelernt) and at least one weil-Satz.
- Check it with a translator and correct mistakes in a different colour.
Done when: the corrected text is in your notebook.$p$, $p$[]$p$::jsonb),
  ($p$plan-2026-11-01-1$p$, '2026-11-01', 1, $p$Clean up and publish the evaluation notebook (60 min)$p$, 40, '{0,1,2,3,4,5,6}', $p$A clean notebook is a small portfolio piece and a revision sheet for interviews.
- Restructure 01-evaluation.ipynb into sections: data, model, CV, confusion matrix, ROC, PR, thresholds. Add a markdown cell above each one with a 2–3 line explanation.
- Restart the kernel and run all cells, so it works top to bottom.
- Push it and link it from the ml-notes README.
Done when: the notebook renders on GitHub with all outputs visible.$p$, $p$[]$p$::jsonb),
  ($p$plan-2026-11-01-2$p$, '2026-11-01', 2, $p$Google ML Crash Course: generalization (45 min)$p$, 30, '{0,1,2,3,4,5,6}', $p$- In the Google ML Crash Course, read the "Datasets, Generalization, and Overfitting" module and do its interactive exercises.
- Add 3 new points you didn't know to your notes.
Done when: the module is done and 3 points are noted.$p$, $p$[{"label": "Google ML Crash Course", "url": "https://developers.google.com/machine-learning/crash-course"}]$p$::jsonb),
  ($p$plan-2026-11-01-3$p$, '2026-11-01', 3, $p$German: podcast + vocab review (15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$- Listen to about 15 minutes of an Easy German Podcast episode (walk, cook or commute while listening).
- Then read through this week's vocabulary pages once and mark the 5 words you keep forgetting.
Done when: one episode chunk is done and 5 words are marked for next week.$p$, $p$[{"label": "Easy German Podcast", "url": "https://www.easygerman.org/podcast"}]$p$::jsonb),
  ($p$plan-2026-11-02-1$p$, '2026-11-02', 1, $p$Decision trees$p$, 30, '{0,1,2,3,4,5,6}', $p$- Watch the StatQuest decision trees video.
- Draw a small tree on paper for a made-up "will the machine fail?" example with 2 features.
- In a notebook, train DecisionTreeClassifier on the breast cancer data with max_depth from 1 to 15. Plot train accuracy and CV accuracy against depth.
Done when: you can point at the depth where overfitting starts on your plot.$p$, $p$[{"label": "StatQuest: Decision and Classification Trees", "url": "https://www.youtube.com/watch?v=_L39rN6gz7Y"}]$p$::jsonb),
  ($p$plan-2026-11-02-2$p$, '2026-11-02', 2, $p$German: Nicos Weg B1 (10–15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$Keep working through the B1 film, a little each time.
- Open the film and continue from the timestamp you wrote down last time (first time: start at 0:00).
- Watch about 10 minutes with German subtitles on. Pause whenever you don't understand a sentence.
- In your German notebook, write 5 new words or phrases with one example sentence each.
- Write today's stop timestamp at the bottom of the page.
Done when: 5 new words are in your notebook and the timestamp is noted.$p$, $p$[{"label": "DW: Nicos Weg B1, full film with subtitles", "url": "https://www.youtube.com/watch?v=LkufozluseI"}, {"label": "DW: Nicos Weg B1, Folge 1 (2 min)", "url": "https://www.youtube.com/watch?v=o1zJ-BNQrU0"}]$p$::jsonb),
  ($p$plan-2026-11-03-1$p$, '2026-11-03', 1, $p$Random forests$p$, 30, '{0,1,2,3,4,5,6}', $p$- Watch StatQuest Random Forests Part 1.
- Compare a single tree with RandomForestClassifier(n_estimators=300) using 5-fold CV and the same metric.
- Write 3 lines in your notes on why averaging many trees reduces variance.
Done when: the CV comparison is printed and the note is written.$p$, $p$[{"label": "StatQuest: Random Forests Part 1", "url": "https://www.youtube.com/watch?v=J4Wdy0Wc_xQ"}]$p$::jsonb),
  ($p$plan-2026-11-03-2$p$, '2026-11-03', 2, $p$German: Easy German + shadowing (10–15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$- Pick one Easy German video of 10 minutes or less (street interviews are ideal) and watch it with German subtitles.
- Choose 3 sentences you like. Pause, repeat each one out loud 3 times and copy the rhythm (shadowing).
- Write the 3 sentences in your notebook.
Done when: you have said 3 sentences out loud and written them down.$p$, $p$[{"label": "Easy German on YouTube", "url": "https://youtube.com/easygerman"}]$p$::jsonb),
  ($p$plan-2026-11-04-1$p$, '2026-11-04', 1, $p$Kaggle Intermediate ML: missing values + categorical$p$, 30, '{0,1,2,3,4,5,6}', $p$- Start Kaggle's Intermediate Machine Learning course.
- Do the lessons "Missing Values" and "Categorical Variables" with their exercises.
Done when: both exercises are complete.$p$, $p$[{"label": "Kaggle Learn: Intermediate Machine Learning", "url": "https://www.kaggle.com/learn/intermediate-machine-learning"}]$p$::jsonb),
  ($p$plan-2026-11-04-2$p$, '2026-11-04', 2, $p$German: Nicos Weg B1 (10–15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$Keep working through the B1 film, a little each time.
- Open the film and continue from the timestamp you wrote down last time (first time: start at 0:00).
- Watch about 10 minutes with German subtitles on. Pause whenever you don't understand a sentence.
- In your German notebook, write 5 new words or phrases with one example sentence each.
- Write today's stop timestamp at the bottom of the page.
Done when: 5 new words are in your notebook and the timestamp is noted.$p$, $p$[{"label": "DW: Nicos Weg B1, full film with subtitles", "url": "https://www.youtube.com/watch?v=LkufozluseI"}, {"label": "DW: Nicos Weg B1, Folge 1 (2 min)", "url": "https://www.youtube.com/watch?v=o1zJ-BNQrU0"}]$p$::jsonb),
  ($p$plan-2026-11-05-1$p$, '2026-11-05', 1, $p$Kaggle Intermediate ML: pipelines$p$, 30, '{0,1,2,3,4,5,6}', $p$Pipelines are the backbone of your project, so take your time today.
- Do the "Pipelines" lesson and exercise.
- Then read the Pipeline and ColumnTransformer sections of the scikit-learn page.
- In your notes, write why a pipeline prevents data leakage during cross-validation.
Done when: the exercise is complete and the note is written.$p$, $p$[{"label": "Kaggle Learn: Intermediate Machine Learning", "url": "https://www.kaggle.com/learn/intermediate-machine-learning"}, {"label": "scikit-learn: Pipelines and ColumnTransformer", "url": "https://scikit-learn.org/stable/modules/compose.html"}]$p$::jsonb),
  ($p$plan-2026-11-05-2$p$, '2026-11-05', 2, $p$German: Easy German + shadowing (10–15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$- Pick one Easy German video of 10 minutes or less (street interviews are ideal) and watch it with German subtitles.
- Choose 3 sentences you like. Pause, repeat each one out loud 3 times and copy the rhythm (shadowing).
- Write the 3 sentences in your notebook.
Done when: you have said 3 sentences out loud and written them down.$p$, $p$[{"label": "Easy German on YouTube", "url": "https://youtube.com/easygerman"}]$p$::jsonb),
  ($p$plan-2026-11-06-1$p$, '2026-11-06', 1, $p$Kaggle Intermediate ML: cross-validation$p$, 30, '{0,1,2,3,4,5,6}', $p$- Do the "Cross-Validation" lesson and exercise.
- Compare it with what you did in week 2. What does putting the pipeline inside cross_val_score change?
Done when: the exercise is complete.$p$, $p$[{"label": "Kaggle Learn: Intermediate Machine Learning", "url": "https://www.kaggle.com/learn/intermediate-machine-learning"}]$p$::jsonb),
  ($p$plan-2026-11-06-2$p$, '2026-11-06', 2, $p$German: Nicos Weg B1 (10–15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$Keep working through the B1 film, a little each time.
- Open the film and continue from the timestamp you wrote down last time (first time: start at 0:00).
- Watch about 10 minutes with German subtitles on. Pause whenever you don't understand a sentence.
- In your German notebook, write 5 new words or phrases with one example sentence each.
- Write today's stop timestamp at the bottom of the page.
Done when: 5 new words are in your notebook and the timestamp is noted.$p$, $p$[{"label": "DW: Nicos Weg B1, full film with subtitles", "url": "https://www.youtube.com/watch?v=LkufozluseI"}, {"label": "DW: Nicos Weg B1, Folge 1 (2 min)", "url": "https://www.youtube.com/watch?v=o1zJ-BNQrU0"}]$p$::jsonb),
  ($p$plan-2026-11-07-1$p$, '2026-11-07', 1, $p$Gradient boosting + XGBoost lesson (60 min)$p$, 40, '{0,1,2,3,4,5,6}', $p$- Watch StatQuest Gradient Boost Part 1 and Part 3. Pause and sketch the idea: each new tree fits the errors of the trees before it.
- Do the Kaggle "XGBoost" lesson and exercise.
Done when: the exercise is complete and your sketch is in your notes.$p$, $p$[{"label": "StatQuest: Gradient Boost Part 1 (Regression)", "url": "https://www.youtube.com/watch?v=3CC4N4z3GJc"}, {"label": "StatQuest: Gradient Boost Part 3 (Classification)", "url": "https://www.youtube.com/watch?v=jxuNLH5dXCs"}, {"label": "Kaggle Learn: Intermediate Machine Learning", "url": "https://www.kaggle.com/learn/intermediate-machine-learning"}]$p$::jsonb),
  ($p$plan-2026-11-07-2$p$, '2026-11-07', 2, $p$Kaggle Intermediate ML: data leakage + certificate (45 min)$p$, 30, '{0,1,2,3,4,5,6}', $p$- Do the "Data Leakage" lesson and exercise. It is one of the most common interview topics.
- Get the certificate and add it to LinkedIn.
- Tick the Kaggle Intermediate ML milestone in the Control tab.
Done when: the certificate is on LinkedIn.$p$, $p$[{"label": "Kaggle Learn: Intermediate Machine Learning", "url": "https://www.kaggle.com/learn/intermediate-machine-learning"}]$p$::jsonb),
  ($p$plan-2026-11-07-3$p$, '2026-11-07', 3, $p$German: write about your week (15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$- By hand, write 6–8 sentences in German: Was habe ich diese Woche gelernt? Was war schwierig? Was mache ich nächste Woche?
- Use Perfekt for the past (ich habe … gelernt) and at least one weil-Satz.
- Check it with a translator and correct mistakes in a different colour.
Done when: the corrected text is in your notebook.$p$, $p$[]$p$::jsonb),
  ($p$plan-2026-11-08-1$p$, '2026-11-08', 1, $p$Regularization: Ridge and Lasso (60 min)$p$, 40, '{0,1,2,3,4,5,6}', $p$- Watch the StatQuest Ridge and Lasso videos.
- In a notebook, use fetch_california_housing and compare LinearRegression, Ridge and Lasso with alphas [0.01, 0.1, 1, 10] using 5-fold CV and RMSE.
- Print which features Lasso pushes to exactly 0 at a high alpha.
Done when: you have a results table and the list of zeroed features.$p$, $p$[{"label": "StatQuest: Ridge (L2) Regression", "url": "https://www.youtube.com/watch?v=Q81RR3yKn30"}, {"label": "StatQuest: Lasso (L1) Regression", "url": "https://www.youtube.com/watch?v=NGf0voTMlcs"}]$p$::jsonb),
  ($p$plan-2026-11-08-2$p$, '2026-11-08', 2, $p$Explain it out loud (45 min)$p$, 30, '{0,1,2,3,4,5,6}', $p$Interviews test whether you can explain things, not whether you watched videos.
- Record yourself on your phone, in English, about 2 minutes per topic: bias vs variance, k-fold CV, precision vs recall, ROC vs PR, random forest vs gradient boosting, and data leakage.
- Listen back. Wherever you hesitated, re-read your notes and record that topic again.
- If you can do all six without notes, tick the "explain without notes" milestone.
Done when: 6 recordings are done, with the weak ones re-recorded.$p$, $p$[]$p$::jsonb),
  ($p$plan-2026-11-08-3$p$, '2026-11-08', 3, $p$German: podcast + vocab review (15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$- Listen to about 15 minutes of an Easy German Podcast episode (walk, cook or commute while listening).
- Then read through this week's vocabulary pages once and mark the 5 words you keep forgetting.
Done when: one episode chunk is done and 5 words are marked for next week.$p$, $p$[{"label": "Easy German Podcast", "url": "https://www.easygerman.org/podcast"}]$p$::jsonb),
  ($p$plan-2026-11-09-1$p$, '2026-11-09', 1, $p$Project kickoff: predictive maintenance$p$, 30, '{0,1,2,3,4,5,6}', $p$For the next 6 weeks you'll build one project end to end: predicting machine failures from sensor data. It fits manufacturing and automotive companies well.
- Read the AI4I 2020 dataset page and download the CSV.
- Create a repo predictive-maintenance-mlops with uv. Folders: data/ (add it to .gitignore), notebooks/, src/, app/, tests/
- Write README v0: the problem (predict machine failure so maintenance happens before a breakdown), the dataset and the planned stack (scikit-learn, MLflow, FastAPI, Docker, GitHub Actions, Hugging Face Spaces, Evidently).
Done when: the repo is on GitHub with README v0 and the folder structure.$p$, $p$[{"label": "UCI: AI4I 2020 Predictive Maintenance dataset", "url": "https://archive.ics.uci.edu/dataset/601/ai4i+2020+predictive+maintenance+dataset"}]$p$::jsonb),
  ($p$plan-2026-11-09-2$p$, '2026-11-09', 2, $p$German: Nicos Weg B1 (10–15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$Keep working through the B1 film, a little each time.
- Open the film and continue from the timestamp you wrote down last time (first time: start at 0:00).
- Watch about 10 minutes with German subtitles on. Pause whenever you don't understand a sentence.
- In your German notebook, write 5 new words or phrases with one example sentence each.
- Write today's stop timestamp at the bottom of the page.
Done when: 5 new words are in your notebook and the timestamp is noted.$p$, $p$[{"label": "DW: Nicos Weg B1, full film with subtitles", "url": "https://www.youtube.com/watch?v=LkufozluseI"}, {"label": "DW: Nicos Weg B1, Folge 1 (2 min)", "url": "https://www.youtube.com/watch?v=o1zJ-BNQrU0"}]$p$::jsonb),
  ($p$plan-2026-11-10-1$p$, '2026-11-10', 1, $p$Load the data and spot the leakage trap$p$, 30, '{0,1,2,3,4,5,6}', $p$- If pandas feels rusty, watch the Corey Schafer video first.
- In notebooks/01-eda.ipynb: load the CSV and check .info(), .describe(), missing values and value_counts of "Machine failure". Expect only about 3% failures.
- Important: the columns TWF, HDF, PWF, OSF and RNF are failure-mode labels. Using them as features would be data leakage. Drop them together with UDI and Product ID.
- Write in README: "Target = Machine failure; dropped columns and why".
Done when: the class balance is printed and the leakage note is in the README.$p$, $p$[{"label": "Corey Schafer: Pandas Tutorial Part 1", "url": "https://www.youtube.com/watch?v=ZyhVh-qRZPA"}, {"label": "UCI: AI4I 2020 Predictive Maintenance dataset", "url": "https://archive.ics.uci.edu/dataset/601/ai4i+2020+predictive+maintenance+dataset"}]$p$::jsonb),
  ($p$plan-2026-11-10-2$p$, '2026-11-10', 2, $p$German: Easy German + shadowing (10–15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$- Pick one Easy German video of 10 minutes or less (street interviews are ideal) and watch it with German subtitles.
- Choose 3 sentences you like. Pause, repeat each one out loud 3 times and copy the rhythm (shadowing).
- Write the 3 sentences in your notebook.
Done when: you have said 3 sentences out loud and written them down.$p$, $p$[{"label": "Easy German on YouTube", "url": "https://youtube.com/easygerman"}]$p$::jsonb),
  ($p$plan-2026-11-11-1$p$, '2026-11-11', 1, $p$Exploratory plots$p$, 30, '{0,1,2,3,4,5,6}', $p$- Plot the distribution of each sensor (air temp, process temp, rotational speed, torque, tool wear), split by failure vs no failure. Use histograms or boxplots.
- Plot the failure rate per product Type (L, M, H).
- Write 3 observations as markdown in the notebook (for example: "failures cluster at high tool wear").
Done when: the plots and 3 written observations are in the notebook.$p$, $p$[]$p$::jsonb),
  ($p$plan-2026-11-11-2$p$, '2026-11-11', 2, $p$German: Nicos Weg B1 (10–15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$Keep working through the B1 film, a little each time.
- Open the film and continue from the timestamp you wrote down last time (first time: start at 0:00).
- Watch about 10 minutes with German subtitles on. Pause whenever you don't understand a sentence.
- In your German notebook, write 5 new words or phrases with one example sentence each.
- Write today's stop timestamp at the bottom of the page.
Done when: 5 new words are in your notebook and the timestamp is noted.$p$, $p$[{"label": "DW: Nicos Weg B1, full film with subtitles", "url": "https://www.youtube.com/watch?v=LkufozluseI"}, {"label": "DW: Nicos Weg B1, Folge 1 (2 min)", "url": "https://www.youtube.com/watch?v=o1zJ-BNQrU0"}]$p$::jsonb),
  ($p$plan-2026-11-12-1$p$, '2026-11-12', 1, $p$Feature engineering$p$, 30, '{0,1,2,3,4,5,6}', $p$- Do the Kaggle Feature Engineering lesson "Mutual Information".
- Add 2 physics-based features: temp_diff = process temp − air temp, and power = torque × rotational speed × 2π/60 (in watts).
- Compute mutual information of every feature with the target and plot it. Are your new features useful?
Done when: the new features and the MI plot are in the notebook.$p$, $p$[{"label": "Kaggle Learn: Feature Engineering", "url": "https://www.kaggle.com/learn/feature-engineering"}]$p$::jsonb),
  ($p$plan-2026-11-12-2$p$, '2026-11-12', 2, $p$German: Easy German + shadowing (10–15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$- Pick one Easy German video of 10 minutes or less (street interviews are ideal) and watch it with German subtitles.
- Choose 3 sentences you like. Pause, repeat each one out loud 3 times and copy the rhythm (shadowing).
- Write the 3 sentences in your notebook.
Done when: you have said 3 sentences out loud and written them down.$p$, $p$[{"label": "Easy German on YouTube", "url": "https://youtube.com/easygerman"}]$p$::jsonb),
  ($p$plan-2026-11-13-1$p$, '2026-11-13', 1, $p$Baseline model in a pipeline$p$, 30, '{0,1,2,3,4,5,6}', $p$- Make a stratified train/test split (test_size=0.2, stratify=y, random_state=42).
- Build a Pipeline with a ColumnTransformer (OneHotEncoder for Type, StandardScaler for the numeric columns) followed by LogisticRegression.
- Compare it with DummyClassifier. Report PR-AUC (average_precision_score), recall and precision on the test set.
Done when: you have a 2-row results table (dummy vs logistic).$p$, $p$[{"label": "scikit-learn: Pipelines and ColumnTransformer", "url": "https://scikit-learn.org/stable/modules/compose.html"}]$p$::jsonb),
  ($p$plan-2026-11-13-2$p$, '2026-11-13', 2, $p$German: Nicos Weg B1 (10–15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$Keep working through the B1 film, a little each time.
- Open the film and continue from the timestamp you wrote down last time (first time: start at 0:00).
- Watch about 10 minutes with German subtitles on. Pause whenever you don't understand a sentence.
- In your German notebook, write 5 new words or phrases with one example sentence each.
- Write today's stop timestamp at the bottom of the page.
Done when: 5 new words are in your notebook and the timestamp is noted.$p$, $p$[{"label": "DW: Nicos Weg B1, full film with subtitles", "url": "https://www.youtube.com/watch?v=LkufozluseI"}, {"label": "DW: Nicos Weg B1, Folge 1 (2 min)", "url": "https://www.youtube.com/watch?v=o1zJ-BNQrU0"}]$p$::jsonb),
  ($p$plan-2026-11-14-1$p$, '2026-11-14', 1, $p$Stronger models with stratified CV (60 min)$p$, 40, '{0,1,2,3,4,5,6}', $p$- Using the same pipeline, try RandomForestClassifier(class_weight="balanced") and HistGradientBoostingClassifier.
- Use StratifiedKFold(5) and cross_validate with scoring average_precision, recall and precision.
- Add both to the results table and pick the best by PR-AUC.
Done when: the results table has 4 models and a chosen winner.$p$, $p$[]$p$::jsonb),
  ($p$plan-2026-11-14-2$p$, '2026-11-14', 2, $p$Move the notebook code into src/train.py (45 min)$p$, 30, '{0,1,2,3,4,5,6}', $p$Notebooks are for exploring. Scripts are what get deployed.
- Create src/features.py with add_features(df) and FEATURES/TARGET constants.
- Create src/train.py: load the data, add the features, build the pipeline, evaluate, then save the model to models/model.joblib and the metrics to models/metrics.json.
- Run it with: uv run python src/train.py
Done when: one command trains and saves the model, and it's committed (without the data and model files).$p$, $p$[]$p$::jsonb),
  ($p$plan-2026-11-14-3$p$, '2026-11-14', 3, $p$German: write about your week (15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$- By hand, write 6–8 sentences in German: Was habe ich diese Woche gelernt? Was war schwierig? Was mache ich nächste Woche?
- Use Perfekt for the past (ich habe … gelernt) and at least one weil-Satz.
- Check it with a translator and correct mistakes in a different colour.
Done when: the corrected text is in your notebook.$p$, $p$[]$p$::jsonb),
  ($p$plan-2026-11-15-1$p$, '2026-11-15', 1, $p$MLOps Zoomcamp module 1 (60 min)$p$, 40, '{0,1,2,3,4,5,6}', $p$- Open the module 1 notes and watch its videos from the playlist (about 60 minutes at 1.25x).
- Write in your notes: what MLOps is, the MLOps maturity levels, and which level your project will reach by December.
Done when: the module 1 videos are done and the notes are written.$p$, $p$[{"label": "MLOps Zoomcamp module 1: Intro (notes + videos)", "url": "https://github.com/DataTalksClub/mlops-zoomcamp/tree/main/01-intro"}, {"label": "MLOps Zoomcamp video playlist (DataTalksClub)", "url": "https://www.youtube.com/playlist?list=PL3MmuxUbc_hIUISrluw_A7wDSmfOhErJK"}]$p$::jsonb),
  ($p$plan-2026-11-15-2$p$, '2026-11-15', 2, $p$Application pipeline: collect 10 postings (45 min)$p$, 30, '{0,1,2,3,4,5,6}', $p$You still need the internship semester, so start a steady flow of applications now.
- Make a sheet with these columns: company, link, role, language, deadline, requirements, status.
- Search the BA Jobsuche, LinkedIn and company career pages for "Pflichtpraktikum Machine Learning", "Praktikum KI", "Werkstudent Data Science" and "MLOps". Include automotive suppliers and startups.
- Save 10 postings that start in 2027. Prefer English-friendly ones, but include a few German ones.
Done when: the sheet has 10 rows.$p$, $p$[{"label": "Bundesagentur für Arbeit: Jobsuche", "url": "https://www.arbeitsagentur.de/jobsuche/"}]$p$::jsonb),
  ($p$plan-2026-11-15-3$p$, '2026-11-15', 3, $p$German: podcast + vocab review (15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$- Listen to about 15 minutes of an Easy German Podcast episode (walk, cook or commute while listening).
- Then read through this week's vocabulary pages once and mark the 5 words you keep forgetting.
Done when: one episode chunk is done and 5 words are marked for next week.$p$, $p$[{"label": "Easy German Podcast", "url": "https://www.easygerman.org/podcast"}]$p$::jsonb),
  ($p$plan-2026-11-16-1$p$, '2026-11-16', 1, $p$MLflow quickstart$p$, 30, '{0,1,2,3,4,5,6}', $p$- Run: uv add mlflow, then work through the MLflow model training quickstart.
- Start the UI with: uv run mlflow ui, and open it in the browser.
- Log one test run with a parameter, a metric and the model.
Done when: you can see your run in the MLflow UI.$p$, $p$[{"label": "MLflow: Model training quickstart", "url": "https://mlflow.org/docs/latest/ml/getting-started/quickstart/"}]$p$::jsonb),
  ($p$plan-2026-11-16-2$p$, '2026-11-16', 2, $p$German: Nicos Weg B1 (10–15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$Keep working through the B1 film, a little each time.
- Open the film and continue from the timestamp you wrote down last time (first time: start at 0:00).
- Watch about 10 minutes with German subtitles on. Pause whenever you don't understand a sentence.
- In your German notebook, write 5 new words or phrases with one example sentence each.
- Write today's stop timestamp at the bottom of the page.
Done when: 5 new words are in your notebook and the timestamp is noted.$p$, $p$[{"label": "DW: Nicos Weg B1, full film with subtitles", "url": "https://www.youtube.com/watch?v=LkufozluseI"}, {"label": "DW: Nicos Weg B1, Folge 1 (2 min)", "url": "https://www.youtube.com/watch?v=o1zJ-BNQrU0"}]$p$::jsonb),
  ($p$plan-2026-11-17-1$p$, '2026-11-17', 1, $p$Track every training run$p$, 30, '{0,1,2,3,4,5,6}', $p$- Add MLflow to src/train.py: mlflow.set_experiment("predictive-maintenance"), then log the model name and its key params, PR-AUC, recall, precision and the model artifact.
- Train 3 different models via a --model argument and compare them in the UI.
Done when: 3 runs appear in the MLflow UI and can be compared.$p$, $p$[{"label": "MLflow: Model training quickstart", "url": "https://mlflow.org/docs/latest/ml/getting-started/quickstart/"}]$p$::jsonb),
  ($p$plan-2026-11-17-2$p$, '2026-11-17', 2, $p$German: Easy German + shadowing (10–15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$- Pick one Easy German video of 10 minutes or less (street interviews are ideal) and watch it with German subtitles.
- Choose 3 sentences you like. Pause, repeat each one out loud 3 times and copy the rhythm (shadowing).
- Write the 3 sentences in your notebook.
Done when: you have said 3 sentences out loud and written them down.$p$, $p$[{"label": "Easy German on YouTube", "url": "https://youtube.com/easygerman"}]$p$::jsonb),
  ($p$plan-2026-11-18-1$p$, '2026-11-18', 1, $p$MLOps Zoomcamp module 2: experiment tracking$p$, 30, '{0,1,2,3,4,5,6}', $p$- Watch the first 30 minutes of module 2 (the experiment tracking videos).
- Note 2 things they do that your train.py doesn't do yet, such as autologging or the model registry.
Done when: the 2 ideas are written down.$p$, $p$[{"label": "MLOps Zoomcamp module 2: Experiment tracking", "url": "https://github.com/DataTalksClub/mlops-zoomcamp/tree/main/02-experiment-tracking"}, {"label": "MLOps Zoomcamp video playlist (DataTalksClub)", "url": "https://www.youtube.com/playlist?list=PL3MmuxUbc_hIUISrluw_A7wDSmfOhErJK"}]$p$::jsonb),
  ($p$plan-2026-11-18-2$p$, '2026-11-18', 2, $p$German: Nicos Weg B1 (10–15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$Keep working through the B1 film, a little each time.
- Open the film and continue from the timestamp you wrote down last time (first time: start at 0:00).
- Watch about 10 minutes with German subtitles on. Pause whenever you don't understand a sentence.
- In your German notebook, write 5 new words or phrases with one example sentence each.
- Write today's stop timestamp at the bottom of the page.
Done when: 5 new words are in your notebook and the timestamp is noted.$p$, $p$[{"label": "DW: Nicos Weg B1, full film with subtitles", "url": "https://www.youtube.com/watch?v=LkufozluseI"}, {"label": "DW: Nicos Weg B1, Folge 1 (2 min)", "url": "https://www.youtube.com/watch?v=o1zJ-BNQrU0"}]$p$::jsonb),
  ($p$plan-2026-11-19-1$p$, '2026-11-19', 1, $p$Hyperparameter tuning, tracked$p$, 30, '{0,1,2,3,4,5,6}', $p$- Use RandomizedSearchCV (n_iter=20, StratifiedKFold(5), scoring="average_precision") on HistGradientBoostingClassifier. Tune learning_rate, max_depth, max_leaf_nodes and l2_regularization.
- Log the best params and score to MLflow. Look at the MLflow tuning tutorial for the nested-runs idea.
Done when: the best tuned run is in MLflow and beats your untuned run.$p$, $p$[{"label": "MLflow: Hyperparameter tuning tutorial", "url": "https://mlflow.org/docs/latest/ml/getting-started/hyperparameter-tuning/"}]$p$::jsonb),
  ($p$plan-2026-11-19-2$p$, '2026-11-19', 2, $p$German: Easy German + shadowing (10–15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$- Pick one Easy German video of 10 minutes or less (street interviews are ideal) and watch it with German subtitles.
- Choose 3 sentences you like. Pause, repeat each one out loud 3 times and copy the rhythm (shadowing).
- Write the 3 sentences in your notebook.
Done when: you have said 3 sentences out loud and written them down.$p$, $p$[{"label": "Easy German on YouTube", "url": "https://youtube.com/easygerman"}]$p$::jsonb),
  ($p$plan-2026-11-20-1$p$, '2026-11-20', 1, $p$Choose the decision threshold$p$, 30, '{0,1,2,3,4,5,6}', $p$A missed failure (false negative) costs more than a false alarm. Choose your threshold on purpose.
- On validation predictions, compute precision and recall for thresholds from 0.05 to 0.95.
- Pick the threshold with recall of at least 0.80 and the best precision. Save it to models/threshold.json and log it to MLflow.
- In the README, explain the trade-off in 3 sentences.
Done when: threshold.json exists and the README explains your choice.$p$, $p$[]$p$::jsonb),
  ($p$plan-2026-11-20-2$p$, '2026-11-20', 2, $p$German: Nicos Weg B1 (10–15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$Keep working through the B1 film, a little each time.
- Open the film and continue from the timestamp you wrote down last time (first time: start at 0:00).
- Watch about 10 minutes with German subtitles on. Pause whenever you don't understand a sentence.
- In your German notebook, write 5 new words or phrases with one example sentence each.
- Write today's stop timestamp at the bottom of the page.
Done when: 5 new words are in your notebook and the timestamp is noted.$p$, $p$[{"label": "DW: Nicos Weg B1, full film with subtitles", "url": "https://www.youtube.com/watch?v=LkufozluseI"}, {"label": "DW: Nicos Weg B1, Folge 1 (2 min)", "url": "https://www.youtube.com/watch?v=o1zJ-BNQrU0"}]$p$::jsonb),
  ($p$plan-2026-11-21-1$p$, '2026-11-21', 1, $p$Explain the model with SHAP (60 min)$p$, 40, '{0,1,2,3,4,5,6}', $p$- Watch StatQuest XGBoost Part 1 (optional, you can skip it if time is short).
- Run: uv add shap. Compute SHAP values for your best model on the test set and make a summary (beeswarm) plot.
- Write in the README which 3 features drive failure predictions, and check that it makes physical sense (torque, tool wear, power).
Done when: the SHAP plot is saved in the repo and explained in the README.$p$, $p$[{"label": "StatQuest: XGBoost Part 1", "url": "https://www.youtube.com/watch?v=OtD8wVaFm6E"}, {"label": "SHAP documentation", "url": "https://shap.readthedocs.io/en/latest/"}]$p$::jsonb),
  ($p$plan-2026-11-21-2$p$, '2026-11-21', 2, $p$Freeze the final model (45 min)$p$, 30, '{0,1,2,3,4,5,6}', $p$- Retrain the best configuration on the full training set and evaluate once on the test set.
- Save model.joblib, metrics.json and threshold.json. Add a results table to the README (model, PR-AUC, recall, precision at your threshold).
- Tag the commit: git tag v0.1-model
Done when: the README results table is filled in and the tag is pushed.$p$, $p$[]$p$::jsonb),
  ($p$plan-2026-11-21-3$p$, '2026-11-21', 3, $p$German: write about your week (15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$- By hand, write 6–8 sentences in German: Was habe ich diese Woche gelernt? Was war schwierig? Was mache ich nächste Woche?
- Use Perfekt for the past (ich habe … gelernt) and at least one weil-Satz.
- Check it with a translator and correct mistakes in a different colour.
Done when: the corrected text is in your notebook.$p$, $p$[]$p$::jsonb),
  ($p$plan-2026-11-22-1$p$, '2026-11-22', 1, $p$Reproducibility check (60 min)$p$, 40, '{0,1,2,3,4,5,6}', $p$- Clone your repo into a fresh folder and follow only the README to train the model. Fix every step that fails or isn't written down.
- Add a "Quickstart" section: uv sync, download the data to data/, uv run python src/train.py, uv run mlflow ui
- Tick the milestone "Predictive maintenance model with MLflow tracking" in the Control tab.
Done when: a fresh clone trains successfully just by following the README.$p$, $p$[]$p$::jsonb),
  ($p$plan-2026-11-22-2$p$, '2026-11-22', 2, $p$Write your master Anschreiben (45 min)$p$, 30, '{0,1,2,3,4,5,6}', $p$- Write one German cover letter template of about 250 words with 4 paragraphs: why this company (a placeholder you adapt each time), what you bring (projects with numbers, including this one), why now (Pflichtpraktikum dates, 5th semester THD), and closing.
- Write an English version too.
- Have a German speaker or a careful translator pass check it.
Done when: both templates are saved as documents.$p$, $p$[]$p$::jsonb),
  ($p$plan-2026-11-22-3$p$, '2026-11-22', 3, $p$German: podcast + vocab review (15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$- Listen to about 15 minutes of an Easy German Podcast episode (walk, cook or commute while listening).
- Then read through this week's vocabulary pages once and mark the 5 words you keep forgetting.
Done when: one episode chunk is done and 5 words are marked for next week.$p$, $p$[{"label": "Easy German Podcast", "url": "https://www.easygerman.org/podcast"}]$p$::jsonb),
  ($p$plan-2026-11-23-1$p$, '2026-11-23', 1, $p$FastAPI first steps$p$, 30, '{0,1,2,3,4,5,6}', $p$- Run: uv add fastapi uvicorn. Then follow FastAPI "First steps" and "Path parameters" in app/main.py.
- Run: uv run uvicorn app.main:app --reload, and open /docs in the browser.
Done when: /docs shows your hello endpoint and you can call it from there.$p$, $p$[{"label": "FastAPI docs: First steps", "url": "https://fastapi.tiangolo.com/tutorial/first-steps/"}, {"label": "FastAPI docs: Path parameters", "url": "https://fastapi.tiangolo.com/tutorial/path-params/"}]$p$::jsonb),
  ($p$plan-2026-11-23-2$p$, '2026-11-23', 2, $p$German: Nicos Weg B1 (10–15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$Keep working through the B1 film, a little each time.
- Open the film and continue from the timestamp you wrote down last time (first time: start at 0:00).
- Watch about 10 minutes with German subtitles on. Pause whenever you don't understand a sentence.
- In your German notebook, write 5 new words or phrases with one example sentence each.
- Write today's stop timestamp at the bottom of the page.
Done when: 5 new words are in your notebook and the timestamp is noted.$p$, $p$[{"label": "DW: Nicos Weg B1, full film with subtitles", "url": "https://www.youtube.com/watch?v=LkufozluseI"}, {"label": "DW: Nicos Weg B1, Folge 1 (2 min)", "url": "https://www.youtube.com/watch?v=o1zJ-BNQrU0"}]$p$::jsonb),
  ($p$plan-2026-11-24-1$p$, '2026-11-24', 1, $p$Request schema with Pydantic$p$, 30, '{0,1,2,3,4,5,6}', $p$- Read FastAPI "Request body".
- Create a Pydantic model MachineReading with these fields: type (L/M/H), air_temperature_k, process_temperature_k, rotational_speed_rpm, torque_nm, tool_wear_min.
- Add realistic limits with Field(ge=..., le=...), based on the min/max values in your EDA.
Done when: /docs shows the schema, and invalid input returns a 422 error.$p$, $p$[{"label": "FastAPI docs: Request body", "url": "https://fastapi.tiangolo.com/tutorial/body/"}]$p$::jsonb),
  ($p$plan-2026-11-24-2$p$, '2026-11-24', 2, $p$German: Easy German + shadowing (10–15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$- Pick one Easy German video of 10 minutes or less (street interviews are ideal) and watch it with German subtitles.
- Choose 3 sentences you like. Pause, repeat each one out loud 3 times and copy the rhythm (shadowing).
- Write the 3 sentences in your notebook.
Done when: you have said 3 sentences out loud and written them down.$p$, $p$[{"label": "Easy German on YouTube", "url": "https://youtube.com/easygerman"}]$p$::jsonb),
  ($p$plan-2026-11-25-1$p$, '2026-11-25', 1, $p$/predict and /health endpoints$p$, 30, '{0,1,2,3,4,5,6}', $p$- Load model.joblib and threshold.json once at startup, not on every request.
- POST /predict: turn the reading into a one-row DataFrame, call add_features(), then predict_proba. Return {failure_probability, will_fail, threshold, model_version}.
- GET /health returns {"status": "ok"}.
Done when: a request from /docs returns a probability between 0 and 1.$p$, $p$[]$p$::jsonb),
  ($p$plan-2026-11-25-2$p$, '2026-11-25', 2, $p$German: Nicos Weg B1 (10–15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$Keep working through the B1 film, a little each time.
- Open the film and continue from the timestamp you wrote down last time (first time: start at 0:00).
- Watch about 10 minutes with German subtitles on. Pause whenever you don't understand a sentence.
- In your German notebook, write 5 new words or phrases with one example sentence each.
- Write today's stop timestamp at the bottom of the page.
Done when: 5 new words are in your notebook and the timestamp is noted.$p$, $p$[{"label": "DW: Nicos Weg B1, full film with subtitles", "url": "https://www.youtube.com/watch?v=LkufozluseI"}, {"label": "DW: Nicos Weg B1, Folge 1 (2 min)", "url": "https://www.youtube.com/watch?v=o1zJ-BNQrU0"}]$p$::jsonb),
  ($p$plan-2026-11-26-1$p$, '2026-11-26', 1, $p$pytest basics$p$, 30, '{0,1,2,3,4,5,6}', $p$- Read the pytest getting-started page (and the freeCodeCamp article if it helps).
- Run: uv add --dev pytest. Write tests/test_features.py with 3 tests for add_features: temp_diff is correct, power is correct, and the input DataFrame isn't changed.
- Run them with: uv run pytest
Done when: 3 green tests.$p$, $p$[{"label": "pytest docs: Get started", "url": "https://docs.pytest.org/en/stable/getting-started.html"}, {"label": "freeCodeCamp: Testing in Python with pytest", "url": "https://www.freecodecamp.org/news/testing-in-python-with-pytest/"}]$p$::jsonb),
  ($p$plan-2026-11-26-2$p$, '2026-11-26', 2, $p$German: Easy German + shadowing (10–15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$- Pick one Easy German video of 10 minutes or less (street interviews are ideal) and watch it with German subtitles.
- Choose 3 sentences you like. Pause, repeat each one out loud 3 times and copy the rhythm (shadowing).
- Write the 3 sentences in your notebook.
Done when: you have said 3 sentences out loud and written them down.$p$, $p$[{"label": "Easy German on YouTube", "url": "https://youtube.com/easygerman"}]$p$::jsonb),
  ($p$plan-2026-11-27-1$p$, '2026-11-27', 1, $p$API tests with TestClient$p$, 30, '{0,1,2,3,4,5,6}', $p$- Write tests/test_api.py using fastapi.testclient.TestClient (run uv add --dev httpx if it's asked for).
- Test that /health returns 200, that /predict with a valid reading returns a probability in [0, 1], that a reading with a negative torque returns 422, and that a missing field returns 422.
Done when: all API tests are green with uv run pytest.$p$, $p$[]$p$::jsonb),
  ($p$plan-2026-11-27-2$p$, '2026-11-27', 2, $p$German: Nicos Weg B1 (10–15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$Keep working through the B1 film, a little each time.
- Open the film and continue from the timestamp you wrote down last time (first time: start at 0:00).
- Watch about 10 minutes with German subtitles on. Pause whenever you don't understand a sentence.
- In your German notebook, write 5 new words or phrases with one example sentence each.
- Write today's stop timestamp at the bottom of the page.
Done when: 5 new words are in your notebook and the timestamp is noted.$p$, $p$[{"label": "DW: Nicos Weg B1, full film with subtitles", "url": "https://www.youtube.com/watch?v=LkufozluseI"}, {"label": "DW: Nicos Weg B1, Folge 1 (2 min)", "url": "https://www.youtube.com/watch?v=o1zJ-BNQrU0"}]$p$::jsonb),
  ($p$plan-2026-11-28-1$p$, '2026-11-28', 1, $p$MLOps Zoomcamp module 4: deployment (60 min)$p$, 40, '{0,1,2,3,4,5,6}', $p$- Watch the module 4 videos about web-service deployment (about 60 minutes at 1.25x).
- Compare their Flask/FastAPI service with yours and note one improvement to make.
Done when: the videos are watched and the improvement is noted (or done).$p$, $p$[{"label": "MLOps Zoomcamp module 4: Deployment", "url": "https://github.com/DataTalksClub/mlops-zoomcamp/tree/main/04-deployment"}, {"label": "MLOps Zoomcamp video playlist (DataTalksClub)", "url": "https://www.youtube.com/playlist?list=PL3MmuxUbc_hIUISrluw_A7wDSmfOhErJK"}]$p$::jsonb),
  ($p$plan-2026-11-28-2$p$, '2026-11-28', 2, $p$Prediction logging for monitoring (45 min)$p$, 30, '{0,1,2,3,4,5,6}', $p$Monitoring in week 8 needs data about what the API sees.
- In /predict, append each request's input, the probability and a timestamp to logs/predictions.jsonl. Add logs/ to .gitignore.
- Add one test that checks a line is written. Use the tmp_path fixture so the test doesn't touch your real logs.
Done when: calling /predict a few times creates the log lines and the test is green.$p$, $p$[]$p$::jsonb),
  ($p$plan-2026-11-28-3$p$, '2026-11-28', 3, $p$German: write an application paragraph (15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$Practise the German you will need for applications.
- By hand, write 6–8 sentences: "Warum ich mich für ein Praktikum im Bereich Machine Learning interessiere".
- Use at least 2 Nebensätze (weil, dass, obwohl) and one Konjunktiv II phrase (ich würde gern …).
- Check it with a translator or a German friend and correct mistakes in a different colour.
Done when: the corrected paragraph is in your notebook.$p$, $p$[]$p$::jsonb),
  ($p$plan-2026-11-29-1$p$, '2026-11-29', 1, $p$Docker video, part 1 (60 min)$p$, 40, '{0,1,2,3,4,5,6}', $p$- Watch the first ~60 minutes of the TechWorld with Nana Docker course: what containers are, images vs containers, and the main commands.
- Install Docker Desktop on Windows (with WSL 2) if you haven't yet, and run: docker run hello-world
Done when: hello-world runs, and you can explain image vs container in one sentence.$p$, $p$[{"label": "TechWorld with Nana: Docker Tutorial (3 h course)", "url": "https://www.youtube.com/watch?v=3c-iBn73dDE"}]$p$::jsonb),
  ($p$plan-2026-11-29-2$p$, '2026-11-29', 2, $p$Send 2 tailored applications (45 min)$p$, 30, '{0,1,2,3,4,5,6}', $p$- Pick the 2 best postings from your sheet.
- For each one, adapt the first paragraph of your Anschreiben to the company and reorder your CV skills to match the posting.
- Send both, then update the status column in your sheet.
Done when: 2 applications are sent and logged.$p$, $p$[]$p$::jsonb),
  ($p$plan-2026-11-29-3$p$, '2026-11-29', 3, $p$German: podcast + vocab review (15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$- Listen to about 15 minutes of an Easy German Podcast episode (walk, cook or commute while listening).
- Then read through this week's vocabulary pages once and mark the 5 words you keep forgetting.
Done when: one episode chunk is done and 5 words are marked for next week.$p$, $p$[{"label": "Easy German Podcast", "url": "https://www.easygerman.org/podcast"}]$p$::jsonb),
  ($p$plan-2026-11-30-1$p$, '2026-11-30', 1, $p$Docker video, part 2$p$, 30, '{0,1,2,3,4,5,6}', $p$- Continue the Docker course from about 1:00 to 1:35: Dockerfile basics, layers, ports, volumes.
- Write a docker-cheatsheet.md in ml-notes with the 10 commands you'll use most.
Done when: the cheat sheet is pushed.$p$, $p$[{"label": "TechWorld with Nana: Docker Tutorial (3 h course)", "url": "https://www.youtube.com/watch?v=3c-iBn73dDE"}]$p$::jsonb),
  ($p$plan-2026-11-30-2$p$, '2026-11-30', 2, $p$German: Nicos Weg B1 (10–15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$Keep working through the B1 film, a little each time.
- Open the film and continue from the timestamp you wrote down last time (first time: start at 0:00).
- Watch about 10 minutes with German subtitles on. Pause whenever you don't understand a sentence.
- In your German notebook, write 5 new words or phrases with one example sentence each.
- Write today's stop timestamp at the bottom of the page.
Done when: 5 new words are in your notebook and the timestamp is noted.$p$, $p$[{"label": "DW: Nicos Weg B1, full film with subtitles", "url": "https://www.youtube.com/watch?v=LkufozluseI"}, {"label": "DW: Nicos Weg B1, Folge 1 (2 min)", "url": "https://www.youtube.com/watch?v=o1zJ-BNQrU0"}]$p$::jsonb),
  ($p$plan-2026-12-01-1$p$, '2026-12-01', 1, $p$Write the Dockerfile$p$, 30, '{0,1,2,3,4,5,6}', $p$- Read "FastAPI in Containers".
- Write a Dockerfile: python:3.12-slim, copy pyproject/lock first, install the dependencies, then copy app/, src/ and models/. CMD runs uvicorn app.main:app --host 0.0.0.0 --port 7860
- Add a .dockerignore (data/, .venv/, mlruns/, logs/, notebooks/).
- Build it with: docker build -t pm-api .
Done when: the image builds without errors.$p$, $p$[{"label": "FastAPI docs: FastAPI in containers (Docker)", "url": "https://fastapi.tiangolo.com/deployment/docker/"}]$p$::jsonb),
  ($p$plan-2026-12-01-2$p$, '2026-12-01', 2, $p$German: Easy German + shadowing (10–15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$- Pick one Easy German video of 10 minutes or less (street interviews are ideal) and watch it with German subtitles.
- Choose 3 sentences you like. Pause, repeat each one out loud 3 times and copy the rhythm (shadowing).
- Write the 3 sentences in your notebook.
Done when: you have said 3 sentences out loud and written them down.$p$, $p$[{"label": "Easy German on YouTube", "url": "https://youtube.com/easygerman"}]$p$::jsonb),
  ($p$plan-2026-12-02-1$p$, '2026-12-02', 1, $p$Run and test the container$p$, 30, '{0,1,2,3,4,5,6}', $p$- Run: docker run -p 7860:7860 pm-api, open localhost:7860/docs and send a prediction.
- Check the image size with docker images. If it's over about 1 GB, find out why (usually the .dockerignore or extra packages).
- Add a "Run with Docker" section to the README.
Done when: a prediction works against the container and the README explains how to run it.$p$, $p$[]$p$::jsonb),
  ($p$plan-2026-12-02-2$p$, '2026-12-02', 2, $p$German: Nicos Weg B1 (10–15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$Keep working through the B1 film, a little each time.
- Open the film and continue from the timestamp you wrote down last time (first time: start at 0:00).
- Watch about 10 minutes with German subtitles on. Pause whenever you don't understand a sentence.
- In your German notebook, write 5 new words or phrases with one example sentence each.
- Write today's stop timestamp at the bottom of the page.
Done when: 5 new words are in your notebook and the timestamp is noted.$p$, $p$[{"label": "DW: Nicos Weg B1, full film with subtitles", "url": "https://www.youtube.com/watch?v=LkufozluseI"}, {"label": "DW: Nicos Weg B1, Folge 1 (2 min)", "url": "https://www.youtube.com/watch?v=o1zJ-BNQrU0"}]$p$::jsonb),
  ($p$plan-2026-12-03-1$p$, '2026-12-03', 1, $p$GitHub Actions basics$p$, 30, '{0,1,2,3,4,5,6}', $p$- Watch the TechWorld with Nana GitHub Actions video (about 30 minutes): workflows, jobs, steps, runners.
- Write down which events (push, pull_request) and steps your pipeline will need.
Done when: you have a sketch of your CI pipeline in your notes.$p$, $p$[{"label": "TechWorld with Nana: GitHub Actions CI/CD", "url": "https://www.youtube.com/watch?v=R8_veQiYBjI"}]$p$::jsonb),
  ($p$plan-2026-12-03-2$p$, '2026-12-03', 2, $p$German: Easy German + shadowing (10–15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$- Pick one Easy German video of 10 minutes or less (street interviews are ideal) and watch it with German subtitles.
- Choose 3 sentences you like. Pause, repeat each one out loud 3 times and copy the rhythm (shadowing).
- Write the 3 sentences in your notebook.
Done when: you have said 3 sentences out loud and written them down.$p$, $p$[{"label": "Easy German on YouTube", "url": "https://youtube.com/easygerman"}]$p$::jsonb),
  ($p$plan-2026-12-04-1$p$, '2026-12-04', 1, $p$CI pipeline: tests + Docker build$p$, 30, '{0,1,2,3,4,5,6}', $p$- Create .github/workflows/ci.yml, triggered on push and pull_request: checkout, set up Python, install uv, uv sync, uv run pytest, then docker build.
- Tests need a model. Either train a tiny model in CI, or make the tests use a small fixture model committed in tests/.
- Push and watch the Actions tab until it's green. Add the CI badge to the README.
Done when: CI is green and the badge shows in the README.$p$, $p$[{"label": "TechWorld with Nana: GitHub Actions CI/CD", "url": "https://www.youtube.com/watch?v=R8_veQiYBjI"}]$p$::jsonb),
  ($p$plan-2026-12-04-2$p$, '2026-12-04', 2, $p$German: Nicos Weg B1 (10–15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$Keep working through the B1 film, a little each time.
- Open the film and continue from the timestamp you wrote down last time (first time: start at 0:00).
- Watch about 10 minutes with German subtitles on. Pause whenever you don't understand a sentence.
- In your German notebook, write 5 new words or phrases with one example sentence each.
- Write today's stop timestamp at the bottom of the page.
Done when: 5 new words are in your notebook and the timestamp is noted.$p$, $p$[{"label": "DW: Nicos Weg B1, full film with subtitles", "url": "https://www.youtube.com/watch?v=LkufozluseI"}, {"label": "DW: Nicos Weg B1, Folge 1 (2 min)", "url": "https://www.youtube.com/watch?v=o1zJ-BNQrU0"}]$p$::jsonb),
  ($p$plan-2026-12-05-1$p$, '2026-12-05', 1, $p$Deploy to Hugging Face Spaces (60 min)$p$, 40, '{0,1,2,3,4,5,6}', $p$- Create a free Hugging Face account and a new Space with the Docker SDK.
- Follow "Your first Docker Space". Your app already listens on port 7860. Add the YAML header with app_port: 7860 to the Space README.
- Push your code (including models/) to the Space repo and wait for the build.
- Open https://<user>-<space>.hf.space/docs and send a prediction.
Done when: a public URL returns predictions.$p$, $p$[{"label": "Hugging Face: Your first Docker Space (FastAPI)", "url": "https://huggingface.co/docs/hub/spaces-sdks-docker-first-demo"}, {"label": "Hugging Face: Docker Spaces", "url": "https://huggingface.co/docs/hub/spaces-sdks-docker"}]$p$::jsonb),
  ($p$plan-2026-12-05-2$p$, '2026-12-05', 2, $p$Make the live demo easy to try (45 min)$p$, 30, '{0,1,2,3,4,5,6}', $p$- Add to the README: the live link, a curl example with a sample reading, and a screenshot of /docs.
- Add a simple architecture line, for example: data → train.py → MLflow → model.joblib → FastAPI → Docker → HF Spaces, with CI on GitHub Actions.
- Tick the milestone "FastAPI + Docker + CI, deployed live".
Done when: someone can try the API in 30 seconds just from the README.$p$, $p$[]$p$::jsonb),
  ($p$plan-2026-12-05-3$p$, '2026-12-05', 3, $p$German: write an application paragraph (15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$Practise the German you will need for applications.
- By hand, write 6–8 sentences: "Warum ich mich für ein Praktikum im Bereich Machine Learning interessiere".
- Use at least 2 Nebensätze (weil, dass, obwohl) and one Konjunktiv II phrase (ich würde gern …).
- Check it with a translator or a German friend and correct mistakes in a different colour.
Done when: the corrected paragraph is in your notebook.$p$, $p$[]$p$::jsonb),
  ($p$plan-2026-12-06-1$p$, '2026-12-06', 1, $p$Best practices pass (60 min)$p$, 40, '{0,1,2,3,4,5,6}', $p$- Skim MLOps Zoomcamp module 6 (best practices): linting, formatting, Makefiles, pre-commit.
- Run: uv add --dev ruff. Then run uv run ruff check . and uv run ruff format . and fix the issues.
- Add ruff to your CI workflow.
Done when: CI runs ruff and pytest, and both are green.$p$, $p$[{"label": "MLOps Zoomcamp module 6: Best practices", "url": "https://github.com/DataTalksClub/mlops-zoomcamp/tree/main/06-best-practices"}]$p$::jsonb),
  ($p$plan-2026-12-06-2$p$, '2026-12-06', 2, $p$Send 2 more applications (45 min)$p$, 30, '{0,1,2,3,4,5,6}', $p$- Add 5 new postings to your sheet, then send 2 tailored applications.
- If you have no reply after 2 weeks, add a follow-up date in the status column.
Done when: 2 more applications are sent and the sheet is updated.$p$, $p$[]$p$::jsonb),
  ($p$plan-2026-12-06-3$p$, '2026-12-06', 3, $p$German: podcast + vocab review (15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$- Listen to about 15 minutes of an Easy German Podcast episode (walk, cook or commute while listening).
- Then read through this week's vocabulary pages once and mark the 5 words you keep forgetting.
Done when: one episode chunk is done and 5 words are marked for next week.$p$, $p$[{"label": "Easy German Podcast", "url": "https://www.easygerman.org/podcast"}]$p$::jsonb),
  ($p$plan-2026-12-07-1$p$, '2026-12-07', 1, $p$MLOps Zoomcamp module 5: monitoring$p$, 30, '{0,1,2,3,4,5,6}', $p$- Watch the first ~30 minutes of module 5: what data drift and model decay are, and what to monitor.
- Note what you could monitor in your API: input drift, the prediction rate and the share of predicted failures.
Done when: a monitoring plan of 3 bullet points is in the README draft.$p$, $p$[{"label": "MLOps Zoomcamp module 5: Monitoring", "url": "https://github.com/DataTalksClub/mlops-zoomcamp/tree/main/05-monitoring"}, {"label": "MLOps Zoomcamp video playlist (DataTalksClub)", "url": "https://www.youtube.com/playlist?list=PL3MmuxUbc_hIUISrluw_A7wDSmfOhErJK"}]$p$::jsonb),
  ($p$plan-2026-12-07-2$p$, '2026-12-07', 2, $p$German: Nicos Weg B1 (10–15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$Keep working through the B1 film, a little each time.
- Open the film and continue from the timestamp you wrote down last time (first time: start at 0:00).
- Watch about 10 minutes with German subtitles on. Pause whenever you don't understand a sentence.
- In your German notebook, write 5 new words or phrases with one example sentence each.
- Write today's stop timestamp at the bottom of the page.
Done when: 5 new words are in your notebook and the timestamp is noted.$p$, $p$[{"label": "DW: Nicos Weg B1, full film with subtitles", "url": "https://www.youtube.com/watch?v=LkufozluseI"}, {"label": "DW: Nicos Weg B1, Folge 1 (2 min)", "url": "https://www.youtube.com/watch?v=o1zJ-BNQrU0"}]$p$::jsonb),
  ($p$plan-2026-12-08-1$p$, '2026-12-08', 1, $p$Evidently drift report$p$, 30, '{0,1,2,3,4,5,6}', $p$- Run: uv add evidently, then follow the Evidently "Data and ML checks" quickstart.
- Make a drift report that compares your training data (as reference) with your test data (as current). Save it as HTML.
Done when: a drift report HTML opens in the browser.$p$, $p$[{"label": "Evidently: Data and ML checks quickstart", "url": "https://docs.evidentlyai.com/quickstart_ml"}]$p$::jsonb),
  ($p$plan-2026-12-08-2$p$, '2026-12-08', 2, $p$German: Easy German + shadowing (10–15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$- Pick one Easy German video of 10 minutes or less (street interviews are ideal) and watch it with German subtitles.
- Choose 3 sentences you like. Pause, repeat each one out loud 3 times and copy the rhythm (shadowing).
- Write the 3 sentences in your notebook.
Done when: you have said 3 sentences out loud and written them down.$p$, $p$[{"label": "Easy German on YouTube", "url": "https://youtube.com/easygerman"}]$p$::jsonb),
  ($p$plan-2026-12-09-1$p$, '2026-12-09', 1, $p$Simulate drift and write monitor.py$p$, 30, '{0,1,2,3,4,5,6}', $p$- Create src/monitor.py: it loads the reference data and logs/predictions.jsonl (or a simulated "new week" file) and writes reports/drift.html.
- Simulate drift: take the test data and add +30 min of tool wear and +5 Nm of torque, then check that the report flags those columns.
- Save a screenshot of the report in the repo.
Done when: the report flags the drifted features, and the screenshot is in the README.$p$, $p$[{"label": "Evidently: Data and ML checks quickstart", "url": "https://docs.evidentlyai.com/quickstart_ml"}]$p$::jsonb),
  ($p$plan-2026-12-09-2$p$, '2026-12-09', 2, $p$German: Nicos Weg B1 (10–15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$Keep working through the B1 film, a little each time.
- Open the film and continue from the timestamp you wrote down last time (first time: start at 0:00).
- Watch about 10 minutes with German subtitles on. Pause whenever you don't understand a sentence.
- In your German notebook, write 5 new words or phrases with one example sentence each.
- Write today's stop timestamp at the bottom of the page.
Done when: 5 new words are in your notebook and the timestamp is noted.$p$, $p$[{"label": "DW: Nicos Weg B1, full film with subtitles", "url": "https://www.youtube.com/watch?v=LkufozluseI"}, {"label": "DW: Nicos Weg B1, Folge 1 (2 min)", "url": "https://www.youtube.com/watch?v=o1zJ-BNQrU0"}]$p$::jsonb),
  ($p$plan-2026-12-10-1$p$, '2026-12-10', 1, $p$Write the project README properly$p$, 30, '{0,1,2,3,4,5,6}', $p$This README is what recruiters will read. Give it a clear structure:
- Problem and why it matters (maintenance costs, downtime)
- Data (source, size, imbalance, leakage columns dropped)
- Approach (features, models compared, CV, threshold choice)
- Results table plus the SHAP insight
- MLOps (MLflow, FastAPI, Docker, CI, HF Spaces, Evidently) with the architecture line
- How to run it, the live demo, and what you'd do next
Done when: every section is filled in and there are no "TODO"s left.$p$, $p$[]$p$::jsonb),
  ($p$plan-2026-12-10-2$p$, '2026-12-10', 2, $p$German: Easy German + shadowing (10–15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$- Pick one Easy German video of 10 minutes or less (street interviews are ideal) and watch it with German subtitles.
- Choose 3 sentences you like. Pause, repeat each one out loud 3 times and copy the rhythm (shadowing).
- Write the 3 sentences in your notebook.
Done when: you have said 3 sentences out loud and written them down.$p$, $p$[{"label": "Easy German on YouTube", "url": "https://youtube.com/easygerman"}]$p$::jsonb),
  ($p$plan-2026-12-11-1$p$, '2026-12-11', 1, $p$Draft a LinkedIn post about the project$p$, 30, '{0,1,2,3,4,5,6}', $p$- Write 120–180 words: the problem, what you built, one surprising thing you learned (for example the leakage columns, or PR-AUC vs ROC), the stack, and the link.
- Add one image (the SHAP plot or the architecture).
- Don't post it yet. You'll post it on Saturday together with your updated profile.
Done when: the post draft and its image are ready.$p$, $p$[]$p$::jsonb),
  ($p$plan-2026-12-11-2$p$, '2026-12-11', 2, $p$German: Nicos Weg B1 (10–15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$Keep working through the B1 film, a little each time.
- Open the film and continue from the timestamp you wrote down last time (first time: start at 0:00).
- Watch about 10 minutes with German subtitles on. Pause whenever you don't understand a sentence.
- In your German notebook, write 5 new words or phrases with one example sentence each.
- Write today's stop timestamp at the bottom of the page.
Done when: 5 new words are in your notebook and the timestamp is noted.$p$, $p$[{"label": "DW: Nicos Weg B1, full film with subtitles", "url": "https://www.youtube.com/watch?v=LkufozluseI"}, {"label": "DW: Nicos Weg B1, Folge 1 (2 min)", "url": "https://www.youtube.com/watch?v=o1zJ-BNQrU0"}]$p$::jsonb),
  ($p$plan-2026-12-12-1$p$, '2026-12-12', 1, $p$Update your CV with the project (60 min)$p$, 40, '{0,1,2,3,4,5,6}', $p$- Add the project at the top of your projects section, in this pattern: what you did + stack + result. Example: "Built and deployed a predictive-maintenance API (scikit-learn, MLflow, FastAPI, Docker, GitHub Actions); PR-AUC X, recall Y at the chosen threshold."
- Apply the CV-audit fixes from week 1. Make sure every line passes the "could I explain this for 2 minutes?" test.
- Update both the English and German versions, and repin the repo on your GitHub profile.
- Tick the milestone "Monitoring report + README write-up".
Done when: both CV versions are updated and exported as PDF.$p$, $p$[]$p$::jsonb),
  ($p$plan-2026-12-12-2$p$, '2026-12-12', 2, $p$Refresh LinkedIn and post (45 min)$p$, 30, '{0,1,2,3,4,5,6}', $p$- Headline idea: "AI student @ THD Deggendorf | ML engineering & MLOps | looking for Pflichtpraktikum / Werkstudent 2027".
- Add the project to Featured, and add the Kaggle certificates.
- Publish Wednesday's post.
Done when: your profile is updated and the post is live.$p$, $p$[]$p$::jsonb),
  ($p$plan-2026-12-12-3$p$, '2026-12-12', 3, $p$German: write an application paragraph (15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$Practise the German you will need for applications.
- By hand, write 6–8 sentences: "Warum ich mich für ein Praktikum im Bereich Machine Learning interessiere".
- Use at least 2 Nebensätze (weil, dass, obwohl) and one Konjunktiv II phrase (ich würde gern …).
- Check it with a translator or a German friend and correct mistakes in a different colour.
Done when: the corrected paragraph is in your notebook.$p$, $p$[]$p$::jsonb),
  ($p$plan-2026-12-13-1$p$, '2026-12-13', 1, $p$ML interviews book: how ML hiring works (60 min)$p$, 40, '{0,1,2,3,4,5,6}', $p$- Read chapters 1 and 2 of Chip Huyen's Machine Learning Interviews Book (ML jobs, interview process).
- Write down which of these role types you're aiming for: ML engineer, MLOps, data scientist. Then list which interview rounds to expect.
Done when: you have a one-page summary with your target role and the expected rounds.$p$, $p$[{"label": "Chip Huyen: Machine Learning Interviews Book", "url": "https://huyenchip.com/ml-interviews-book/"}]$p$::jsonb),
  ($p$plan-2026-12-13-2$p$, '2026-12-13', 2, $p$Send 2 more applications (45 min)$p$, 30, '{0,1,2,3,4,5,6}', $p$- Now lead with the new project in your Anschreiben: add one sentence with the live demo link.
- Send 2 tailored applications and update your sheet.
Done when: 2 more applications are sent.$p$, $p$[]$p$::jsonb),
  ($p$plan-2026-12-13-3$p$, '2026-12-13', 3, $p$German: podcast + vocab review (15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$- Listen to about 15 minutes of an Easy German Podcast episode (walk, cook or commute while listening).
- Then read through this week's vocabulary pages once and mark the 5 words you keep forgetting.
Done when: one episode chunk is done and 5 words are marked for next week.$p$, $p$[{"label": "Easy German Podcast", "url": "https://www.easygerman.org/podcast"}]$p$::jsonb),
  ($p$plan-2026-12-14-1$p$, '2026-12-14', 1, $p$Interview prep: ML workflow questions$p$, 30, '{0,1,2,3,4,5,6}', $p$- In the ML Interviews Book, open chapter 7 (ML workflows).
- Answer 5 questions in writing, using your project as the example wherever you can (data leakage, imbalanced data, evaluation metrics, train/test split, baseline).
Done when: you have 5 written answers.$p$, $p$[{"label": "Chip Huyen: Machine Learning Interviews Book", "url": "https://huyenchip.com/ml-interviews-book/"}]$p$::jsonb),
  ($p$plan-2026-12-14-2$p$, '2026-12-14', 2, $p$German: Nicos Weg B1 (10–15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$Keep working through the B1 film, a little each time.
- Open the film and continue from the timestamp you wrote down last time (first time: start at 0:00).
- Watch about 10 minutes with German subtitles on. Pause whenever you don't understand a sentence.
- In your German notebook, write 5 new words or phrases with one example sentence each.
- Write today's stop timestamp at the bottom of the page.
Done when: 5 new words are in your notebook and the timestamp is noted.$p$, $p$[{"label": "DW: Nicos Weg B1, full film with subtitles", "url": "https://www.youtube.com/watch?v=LkufozluseI"}, {"label": "DW: Nicos Weg B1, Folge 1 (2 min)", "url": "https://www.youtube.com/watch?v=o1zJ-BNQrU0"}]$p$::jsonb),
  ($p$plan-2026-12-15-1$p$, '2026-12-15', 1, $p$Interview prep: ML algorithm questions$p$, 30, '{0,1,2,3,4,5,6}', $p$- In chapter 8 (ML algorithms), answer 5 questions on topics you studied: logistic regression, trees, random forest, boosting, regularization.
- Use your StatQuest notes, then try to answer once more without them.
Done when: you have 5 written answers.$p$, $p$[{"label": "Chip Huyen: Machine Learning Interviews Book", "url": "https://huyenchip.com/ml-interviews-book/"}]$p$::jsonb),
  ($p$plan-2026-12-15-2$p$, '2026-12-15', 2, $p$German: Easy German + shadowing (10–15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$- Pick one Easy German video of 10 minutes or less (street interviews are ideal) and watch it with German subtitles.
- Choose 3 sentences you like. Pause, repeat each one out loud 3 times and copy the rhythm (shadowing).
- Write the 3 sentences in your notebook.
Done when: you have said 3 sentences out loud and written them down.$p$, $p$[{"label": "Easy German on YouTube", "url": "https://youtube.com/easygerman"}]$p$::jsonb),
  ($p$plan-2026-12-16-1$p$, '2026-12-16', 1, $p$Your 2-minute project pitch (EN + DE)$p$, 30, '{0,1,2,3,4,5,6}', $p$- Write a 2-minute pitch for the project: situation, what you built, the hardest problem, the result, and what you'd improve.
- Record it in English, then in German. A simpler German version is fine.
- Listen back and cut anything that is filler.
Done when: there are 2 recordings under 2:15 each.$p$, $p$[]$p$::jsonb),
  ($p$plan-2026-12-16-2$p$, '2026-12-16', 2, $p$German: Nicos Weg B1 (10–15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$Keep working through the B1 film, a little each time.
- Open the film and continue from the timestamp you wrote down last time (first time: start at 0:00).
- Watch about 10 minutes with German subtitles on. Pause whenever you don't understand a sentence.
- In your German notebook, write 5 new words or phrases with one example sentence each.
- Write today's stop timestamp at the bottom of the page.
Done when: 5 new words are in your notebook and the timestamp is noted.$p$, $p$[{"label": "DW: Nicos Weg B1, full film with subtitles", "url": "https://www.youtube.com/watch?v=LkufozluseI"}, {"label": "DW: Nicos Weg B1, Folge 1 (2 min)", "url": "https://www.youtube.com/watch?v=o1zJ-BNQrU0"}]$p$::jsonb),
  ($p$plan-2026-12-17-1$p$, '2026-12-17', 1, $p$Coding practice: metrics from scratch$p$, 30, '{0,1,2,3,4,5,6}', $p$Live-coding rounds often ask for basics without libraries.
- In plain Python plus numpy (no sklearn), write train_test_split, a confusion matrix, precision, recall and F1.
- Check your results against sklearn on the same data.
Done when: your functions match the sklearn output.$p$, $p$[]$p$::jsonb),
  ($p$plan-2026-12-17-2$p$, '2026-12-17', 2, $p$German: Easy German + shadowing (10–15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$- Pick one Easy German video of 10 minutes or less (street interviews are ideal) and watch it with German subtitles.
- Choose 3 sentences you like. Pause, repeat each one out loud 3 times and copy the rhythm (shadowing).
- Write the 3 sentences in your notebook.
Done when: you have said 3 sentences out loud and written them down.$p$, $p$[{"label": "Easy German on YouTube", "url": "https://youtube.com/easygerman"}]$p$::jsonb),
  ($p$plan-2026-12-18-1$p$, '2026-12-18', 1, $p$Follow up on applications$p$, 30, '{0,1,2,3,4,5,6}', $p$- Go through your sheet. For anything older than 2 weeks with no answer, send a short, polite follow-up email (German or English, matching the posting).
- Send 1 new application.
Done when: the follow-ups are sent and the sheet is updated.$p$, $p$[]$p$::jsonb),
  ($p$plan-2026-12-18-2$p$, '2026-12-18', 2, $p$German: Nicos Weg B1 (10–15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$Keep working through the B1 film, a little each time.
- Open the film and continue from the timestamp you wrote down last time (first time: start at 0:00).
- Watch about 10 minutes with German subtitles on. Pause whenever you don't understand a sentence.
- In your German notebook, write 5 new words or phrases with one example sentence each.
- Write today's stop timestamp at the bottom of the page.
Done when: 5 new words are in your notebook and the timestamp is noted.$p$, $p$[{"label": "DW: Nicos Weg B1, full film with subtitles", "url": "https://www.youtube.com/watch?v=LkufozluseI"}, {"label": "DW: Nicos Weg B1, Folge 1 (2 min)", "url": "https://www.youtube.com/watch?v=o1zJ-BNQrU0"}]$p$::jsonb),
  ($p$plan-2026-12-19-1$p$, '2026-12-19', 1, $p$Mock interview (60 min)$p$, 40, '{0,1,2,3,4,5,6}', $p$Answer each question out loud, with a 2-minute timer, and record yourself:
- Tell me about yourself.
- Walk me through your predictive-maintenance project.
- Why PR-AUC and not accuracy?
- What is data leakage? Give an example from your project.
- Random forest vs gradient boosting?
- How would you know your model got worse in production?
- What does your CI pipeline do?
- Why should we hire you for the Pflichtpraktikum?
- Tell me about a team conflict or a hard deadline (use the hackathon).
- What questions do you have for us?
Done when: all 10 are answered and the 3 weakest are re-recorded.$p$, $p$[]$p$::jsonb),
  ($p$plan-2026-12-19-2$p$, '2026-12-19', 2, $p$Retro: what worked in these 2 months (45 min)$p$, 30, '{0,1,2,3,4,5,6}', $p$- Create retro-2026.md in ml-notes. Write down: how many plan days you completed (check the Plan tab), your best streak, what you'll keep doing, what you'll drop, and how many hours per week were realistic around your shifts.
- List what is still weak: topics, German, applications.
Done when: retro-2026.md is pushed.$p$, $p$[]$p$::jsonb),
  ($p$plan-2026-12-19-3$p$, '2026-12-19', 3, $p$German: write an application paragraph (15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$Practise the German you will need for applications.
- By hand, write 6–8 sentences: "Warum ich mich für ein Praktikum im Bereich Machine Learning interessiere".
- Use at least 2 Nebensätze (weil, dass, obwohl) and one Konjunktiv II phrase (ich würde gern …).
- Check it with a translator or a German friend and correct mistakes in a different colour.
Done when: the corrected paragraph is in your notebook.$p$, $p$[]$p$::jsonb),
  ($p$plan-2026-12-20-1$p$, '2026-12-20', 1, $p$Plan the next 2 months (45 min)$p$, 30, '{0,1,2,3,4,5,6}', $p$- Look at the roadmap in the Control tab. The next big milestone is the LLM / RAG project (P2).
- Take your retro to Claude and ask for plan v2 (January – February), built around your exam period and your realistic weekly hours.
- Celebrate: you finished a 60-day plan and have a deployed MLOps project.
Done when: plan v2 is requested and your exam dates are in your calendar.$p$, $p$[]$p$::jsonb),
  ($p$plan-2026-12-20-2$p$, '2026-12-20', 2, $p$German: podcast + vocab review (15 min)$p$, 10, '{0,1,2,3,4,5,6}', $p$- Listen to about 15 minutes of an Easy German Podcast episode (walk, cook or commute while listening).
- Then read through this week's vocabulary pages once and mark the 5 words you keep forgetting.
Done when: one episode chunk is done and 5 words are marked for next week.$p$, $p$[{"label": "Easy German Podcast", "url": "https://www.easygerman.org/podcast"}]$p$::jsonb)
on conflict (plan_key) do update set
  day = excluded.day, sort_order = excluded.sort_order, title = excluded.title, xp = excluded.xp,
  details = excluded.details, links = excluded.links, archived_at = null;
