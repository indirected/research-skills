# How to do good research, get it published in SIGKDD and get it cited!

Eamonn Keogh
Computer Science & Engineering Department
University of California - Riverside
Riverside, CA 92521
eamonn@cs.ucr.edu

---

## Disclaimers I

- I don't have a magic bullet for publishing in SIGKDD
  - This is simply my best effort to the community, especially young faculty, grad students and "outsiders".
- For every piece of advice where I tell you "you should do this" or "you should never do this"…
  - You will be able to find counterexamples, including ones that won best paper awards etc.
- I will be critiquing some published papers (including some of my own), however I mean no offence.
  - Of course, these are published papers, so the authors could legitimately say I am wrong.

---

## Disclaimers II

- These slides are meant to be presented, and then studied offline. To allow them to be self-contained like this, I had to break my rule about keeping the number of words to a minimum.

- You have a PDF copy of these slides, if you want a PowerPoint version, email me.

- I plan to continually update these slides, so if you have any feedback/suggestions/criticisms please let me know.

---

## Disclaimers III

- Many of the positive examples are mine, making this tutorial seem self indulgent and vain.

- I did this simply because…
  - I know what reviewers said for my papers.
  - I know the reasoning behind the decisions in my papers.
  - I know when earlier versions of my papers got rejected, and why, and how this was fixed.

---

## Disclaimers IIII

- Many of the ideas I will share are very simple, you might find them insultingly simple.
- Nevertheless at least half of papers submitted to SIGKDD have at least one of these simple flaws.

---

## The Following People Offered Advice

- Geoff Webb
- Frans Coenen
- Cathy Blake
- Michael Pazzani
- Lane Desborough
- Stephen North
- Fabian Moerchen
- Ankur Jain
- Themis Palpanas
- Jeff Scargle
- Howard J. Hamilton
- Mark Last
- Chen Li
- Magnus Lie Hetland
- David Jensen
- Chris Clifton
- Oded Goldreich
- Michalis Vlachos
- Claudia Bauzer Medeiros
- Chunsheng Yang
- Xindong Wu
- Lee Giles
- Johannes Fuernkranz
- Vineet Chaoji
- Stephen Few
- Wolfgang Jank
- Claudia Perlich
- Mitsunori Ogihara
- Hui Xiong
- Chris Drummond
- Charles Ling
- Charles Elkan
- Jieping Ye
- Saeed Salem
- Tina Eliassi-Rad
- Parthasarathy Srinivasan
- Mohammad Hasan
- Vibhu Mittal
- Chris Giannella
- Frank Vahid
- Carla Brodley
- Ansaf Salleb-Aouissi
- Tomas Skopal
- Frans Coenen
- Sang-Hee Lee
- Michael Carey
- Vijay Atluri
- Shashi Shekhar
- Jennifer Windom
- Hui Yang

My students: Jessica Lin, Chotirat Ratanamahatana, Li Wei, Xiaopeng Xi, Dragomir Yankov, Lexiang Ye, Xiaoyue (Elaine) Wang, Jin-Wien Shieh, Abdullah Mueen, Qiang Zhu, Bilson Campana

These people are not responsible for any controversial or incorrect claims made here

---

## Outline

- The Review Process
- Writing a SIGKDD paper
  - Finding problems/data
    - Framing problems
    - Solving problems
  - Tips for writing
    - Motivating your work
    - Clear writing
    - Clear figures
- The top ten reasons papers get rejected
  - With solutions

---

## The Curious Case of Srikanth Krishnamurthy

- In 2004 Srikanth's student submitted a paper to MobiCom
- Deciding to change the title, the student resubmitted the paper, accidentally submitting it as a new paper
- One version of the paper scored 1,2 and 3, and was rejected, the other version scored a 3,4 and 5, and was accepted!

- This "natural" experiments suggests that the reviewing process is random, is it really that bad?

---

## A look at the reviewing statistics for a recent SIGKDD (I cannot say what year)

30 papers were accepted

Mean number of reviews 3.02 — 104 papers accepted

Mean and standard deviation among review scores for papers submitted to recent SIGKDD

- Papers accepted after a discussion, not solely based on the mean score.
- These are final scores, after reviewer discussions.
- The variance in reviewer scores is much larger than the differences in the mean score, for papers on the boundary between accept and reject.
- In order to halve the standard deviation we must quadruple the number of reviews.

---

## Conference reviewing is an imperfect system. We must learn to live with rejection.

30 papers were accepted

All we can do is try to make sure that our paper lands as far left as possible

Mean and standard deviation among review scores for papers submitted to recent SIGKDD

- At least three papers with a score of 3.67 (or lower) must have been accepted. But there were a total of 41 papers that had a score of 3.67.
- That means there exist at least 38 papers that were rejected, that had the same or better numeric score as some papers that were accepted.
- Bottom Line: With very high probability, multiple papers will be rejected in favor of less worthy papers.

---

## A sobering experiment

30 papers were accepted

- Suppose I add one reasonable review to each paper.
- A reasonable review is one that is drawn uniformly from the range of one less than the lowest score to one higher than the highest score.
- If we do this, then on average, 14.1 papers move across the accept/reject borderline. This suggests a very brittle system.

---

## But the good news is…

30 papers were accepted

Most of us only need to improve a little to improve our odds a lot.

Mean and standard deviation among review scores for papers submitted to recent SIGKDD

- Suppose you are one of the 41 groups in the green (light) area. If you can convince just one reviewer to increase their ranking by just one point, you go from near certain reject to near certain accept.
- Suppose you are one of the 140 groups in the blue (bold) area. If you can convince just one reviewer to increase their ranking by just one point, you go from near certain reject to a good chance at accept.

---

## Idealized Algorithm for Writing a Paper

- Find problem/data
- Start writing (yes, start writing before and during research)
- Do research/solve problem
- Finish 95% draft

One month before deadline:
- Send preview to mock reviewers
- Send preview to the rival authors (virtually or literally)
- Revise using checklist.
- Submit

---

## What Makes a Good Research Problem?

- It is important: If you can solve it, you can make money, or save lives, or help children learn a new language, or...
- You can get real data: Doing DNA analysis of the Loch Ness Monster would be interesting, but…
- You can make incremental progress: Some problems are all-or-nothing. Such problems may be too risky for young scientists.
- There is a clear metric for success: Some problems fulfill the criteria above, but it is hard to know when you are making progress on them.

---

## Finding Problems/Finding Data

- Finding a good problem can be the hardest part of the whole process.
- Once you have a problem, you will need data…
- As I shall show in the next few slides, finding problems and finding data are best integrated.

- However, the obvious way to find problems is the best, read lots of papers, both in SIGKDD and elsewhere.

---

## Domain Experts as a Source of Problems

- Data miners are almost unique in that they can work with almost any scientist or business
- I have worked with anthropologists, nematologists, archaeologists, astronomers, entomologists, cardiologists, herpetologists, electroencephalographers, geneticists, space vehicle technicians etc
- Such collaborations can be a rich source of interesting problems.

---

## Working with Domain Experts I

- Getting problems from domain experts might come with some bonuses
- Domain experts can help with the motivation for the paper
  - ..insects cause 40 billion dollars of damage to crops each year..
  - ..compiling a dictionary of such patterns would help doctors diagnosis..
  - Petroglyphs are one of the earliest expressions of abstract thinking, and a true hallmark...

- Domain experts sometimes have funding/internships etc
- Co-authoring with domain experts can give you credibility.

SIGKDD 09

---

## Working with Domain Experts II

> If I had asked my customers what they wanted, they would have said a faster horse
> — Henry Ford

- Ford focused not on stated need but on latent need.
- In working with domain experts, don't just ask them what they want. Instead, try to learn enough about their domain to understand their latent needs.
- In general, domain experts have little idea about what is hard/easy for computer scientists.

---

## Working with Domain Experts III

Concrete Example:

- I once had a biologist spend an hour asking me about sampling/estimation. She wanted to estimate a quantity.
- After an hour I realized that we did not have to estimate it, we could compute an exact answer!
- The exact computation did take three days, but it had taken several years to gather the data.
- Understand the latent need.

---

## Finding Research Problems

- Suppose you think idea X is very good
- Can you extend X by…
  - Making it more accurate (statistically significantly more accurate)
  - Making it faster (usually an order of magnitude, or no one cares)
  - Making it an anytime algorithm
  - Making it an online (streaming) algorithm
  - Making it work for a different data type (including uncertain data)
  - Making it work on low powered devices
  - Explaining why it works so well
  - Making it work for distributed systems
  - Applying it in a novel setting (industrial/government track)
  - Removing a parameter/assumption
  - Making it disk-aware (if it is currently a main memory algorithm)
  - Making it simpler

---

## Finding Research Problems (examples)

- Suppose you think idea X is a very good
- Can you extend X by…
  - Making it more accurate (statistically significantly more accurate)
  - Making it faster (usually an order of magnitude, or no one cares)
  - Making it an anytime algorithm
  - Making it an online (streaming) algorithm
  - Making it work for a different data type (including uncertain data)
  - Making it work on low powered devices
  - Explaining why it works so well
  - Making it work for distributed systems
  - Applying it in a novel setting (industrial/government track)
  - Removing a parameter/assumption
  - Making it disk-aware (if it is currently a main memory algorithm)

- The Nearest Neighbor Algorithm is very useful. I wondered if we could make it an anytime algorithm…. ICDM06 [b].
- Motif discovery is very useful for DNA, would it be useful for time series? SIGKDD03 [c]
- The bottom-up algorithm is very useful for batch data, could we make it work in an online setting? ICDM01 [d]
- Chaos Game Visualization of DNA is very useful, would it be useful for other kinds of data? SDM05 [a]

[a] Kumar, N., Lolla N., Keogh, E., Lonardi, S., Ratanamahatana, C. A. and Wei, L. (2005). Time-series Bitmaps: ICDM 2006
[b] Ueno, Xi, Keogh, Lee. Anytime Classification Using the Nearest Neighbor Algorithm with Applications to Stream Mining. ICDM 2006.
[c] Chiu, B. Keogh, E., & Lonardi, S. (2003). Probabilistic Discovery of Time Series Motifs. SIGKDD 2003
[d] Keogh, E., Chu, S., Hart, D. & Pazzani, M. An Online Algorithm for Segmenting Time Series. ICDM 2001

---

## Finding Research Problems

- Suppose you think idea X is a very good
- Can you extend X by…
  - Making it more accurate (statistically significantly more accurate)
  - Making it faster (usually an order of magnitude, or no one cares)
  - Making it an anytime algorithm
  - Making it an online (streaming) algorithm
  - Making it work for a different data type (including uncertain data)
  - Making it work on low powered devices
  - Explaining why it works so well
  - Making it work for distributed systems
  - Applying it in a novel setting (industrial/government track)
  - Removing a parameter/assumption
  - Making it disk-aware (if it is currently a main memory algorithm)

- Some people have suggested that this method can lead to incremental, boring, low-risk papers…
  - Perhaps, but there are 104 papers in SIGKDD this year, they are not all going to be groundbreaking.
  - Sometimes ideas that seem incremental at first blush may turn out to be very exciting as you explore the problem.
  - An early career person might eventually go on to do high risk research, after they have a "cushion" of two or three lower-risk SIGKDD papers.

---

## Framing Research Problems I

As a reviewer, I am often frustrated by how many people don't have a clear problem statement in the abstract (or the entire paper!)
Can you write a research statement for your paper in a single sentence?
- X is good for Y (in the context of Z).
- X can be extended to achieve Y (in the context of Z).
- The adoption of X facilitates Y (for data in Z format).
- An X approach to the problem of Y mitigates the need for Z.
  (An anytime algorithm approach to the problem of nearest neighbor classification mitigates the need for high performance hardware) (Ueno et al. ICDM 06)

If I, as a reviewer, cannot form such a sentence for your paper after reading just the abstract, then your paper is usually doomed.

> I hate it when a paper under review does not give a concise definition of the problem
> — Tina Eliassi-Rad

See talk by Frans Coenen on this topic: http://www.csc.liv.ac.uk/~frans/Seminars/doingAphdSeminarAI2007.pdf

---

## Framing Research Problems II

Your research statement should be falsifiable

A real paper claims:
> To the best of our knowledge, this is most sophisticated subsequence matching solution mentioned in the literature.

Is there a way that we could show this is not true?

Falsifiability (or refutability) is the logical possibility that an claim can be shown false by an observation or a physical experiment. That something is 'falsifiable' does not mean it is false; rather, that if it is false, then this can be shown by observation or experiment

Falsifiability is the demarcation between science and nonscience — Karl Popper

---

## Framing Research Problems III

Examples of falsifiable claims:
- Quicksort is faster than bubblesort. (this may needed expanding, if the lists are.. )
- The X function lower bounds the DTW distance.
- The L2 distance measure generally outperforms L1 measure (this needs some work (under what conditions etc), but it is falsifiable)

Examples of unfalsifiable claims:
- We can approximately cluster DNA with DFT.
  - Any random arrangement of DNA could be considered a "clustering".

- We present an alterative approach through Fourier harmonic projections to enhance the visualization. The experimental results demonstrate significant improvement of the visualizations.
  - Since "enhance" and "improvement" are subjective and vague, this is unfalsifiable. Note that it could be made falsifiable. Consider:
    - We improve the mean time to find an embedded pattern by a factor of ten.
    - We enhanced the separability of weekdays and weekends, as measured by..

---

## From the Problem to the Data

- At this point we have a concrete, falsifiable research problem
- Now is the time to get data!

By "now", I mean months before the deadline. I have one of the largest collections of free datasets in the world. Each year I am amazed at how many emails I get a few days before the SIGKDD deadline that asks "we want to submit a paper to SIGKDD, do you have any datasets that.. "

- Interesting, real (large, when appropriate) datasets greatly increase your papers chances.
- Having good data will also help do better research, by preventing you from converging on unrealistic solutions.
- Early experience with real data can feed back into the finding and framing the research question stage.

- Given the above, we are going to spend some time considering data..

---

## Is it OK to Make Data?

There is a huge difference between…

We wrote a Matlab script to create random trajectories

and…

We glued tiny radio transmitters to the backs of Mormon crickets and tracked the trajectories

Photo by Jaime Holguin

---

## Why is Synthetic Data so Bad?

Suppose you say "Here are the results on our synthetic dataset:"

|          | Our Method | Their Method |
|----------|-----------|--------------|
| Accuracy | 95%       | 80%          |

This is good right? After all, you are doing much better than your rival.

---

## Why is Synthetic Data so Bad?

But as far as I know, you might have created ten versions of your dataset, but only reported one!

Even if you did not do this consciously, you may have done it unconsciously.

At best, your making of your test data is a huge conflict of interest.

|          | Our Method | Their Method |
|----------|-----------|--------------|
| Accuracy | 80%       | 85%          |
| Accuracy | 75%       | 85%          |
| Accuracy | 90%       | 90%          |
| Accuracy | 95%       | 80%          |
| Accuracy | 85%       | 95%          |

---

## Why is Synthetic Data so Bad?

Note that is does not really make a difference if you have real data but you modify it somehow, it is still synthetic data.

A paper has a section heading: **Results on Two Real Data Sets**

But then we read…

> We add some noises to a small number of shapes in both data sets to manually create some anomalies.

Is this still real data? The answer is no, even if they authors had explained how they added noise (which they don't).

Note that there are probably a handful of circumstances were taking real data, doing an experiment, tweaking the data and repeating the experiment is genuinely illuminating.

---

## Synthetic Data can lead to a Contradiction

- Avoid the contradiction of claiming that the problem is very important, but there is no real data.
- If the problem is as important as you claim, a reviewer would wonder why there is no real data.
- I encounter this contradiction very frequently, here is a real example:

  - Early in the paper: The ability to process large datasets becomes more and more important…
  - Later in the paper: ..because of the lack of publicly available large datasets…

---

## I want to convince you that the effort it takes to find or create real data is worthwhile.

In 2003, I spent two full days recording a video dataset. The data consisted of my student Chotirat (Ann) Ratanamahatana performing actions in front of a green screen.

Was this a waste of two days?

[Figure: Hand gesture time series showing states: Hand at rest, Hand moving above holster, Hand moving down to grasp gun, Hand moving to shoulder level, Steady pointing]

---

## SDM 04 / VLDB 04 / SIGKDD 04 / SDM 05

I have used this data in at least a dozen papers, and one dataset derived from it, the GUN/NOGUN problem, has been used in well over 100 other papers (all of which reference my work!)

Spending the time to make/obtain/clean good datasets will pay off in the long run

SIGKDD 09

---

## The vast majority of papers on shape mining use the MPEG-7 dataset.

Visually, they are telling us: "I can tell the difference between Mickey Mouse and spoon".

The problem is not that I think this easy, the problem is I just don't care.

Show me data I care about

---

## Real data motivates your clever algorithms: Part I

This figure tells me "if I rotate my hand drawn apples, then I will need to have a rotation invariant algorithm to find them"

Figure 3: shapes of natural objects can be from different views of the same object, shapes can be rotated, scaled, skewed

In contrast, this figure tells me "Even in this important domain, where tens of millions of dollars are spent each year, the robots that handle the wings cannot guarantee that they can present them in the same orientation each time. Therefore I will need to have a rotation invariant algorithm"

Figure 5: Two sample wing images from a collection of Drosophila images. Note that the rotation of images can vary even in such a structured domain

---

## Real data motivates your clever algorithms: Part II

This figure tells me "if I use Photoshop to take a chunk out of a drawing of an apple, then I will need an occlusion resistant algorithm to match it back to the original"

In contrast, this figure tells me "In this important domain of cultural artifacts it is common to have objects which are effectively occluded by breakage. Therefore I will need to have an occlusion resistant algorithm"

Figure 15: Project points are frequently found with broken tips or tangs. Such objects require LCSS to find meaningful matches to complete specimens.

---

## Here is a great example. This paper is not technically deep.

However, instead of classifying synthetic shapes, they have a very cool problem (fish counting/classification) and they made an effort to create a very interesting dataset.

Show me data someone cares about

---

## How big does my Dataset need to be?

It depends…

Suppose you are proposing an algorithm for mining Neanderthal bones.
  There are only a few hundred specimens known, and it is very unlikely that number will double in our lifetime. So you could reasonably test on a synthetic* dataset with a mere 1,000 objects.

However…

Suppose you are proposing an algorithm for mining Portuguese web pages (there are billions) or some new biometric (there may soon be millions). You do have an obligation to test on large datasets.

It is increasing difficult to excuse data mining papers testing on small datasets. Data is typically free, CPU cycles are essentially free, a terabyte of storage costs less than $100…

*In this case, the "synthetic" could be easer to obtain monkey bones etc.

---

## Where do I get Good Data?

- From your domain expert collaborators:
- From formal data mining archives:
  - The UCI Knowledge Discovery in Databases Archive.
  - The UCR Time Series and Shape Archive.
- From general archives:
  - Chart-O-Matic
  - NASA GES DISC
- From creating it:
  - Glue tiny radio transmitters to the backs of Mormon crickets…
  - By a Wii, and hire a ASL interpreter to…
- Remember there is no excuse for not getting real data.

---

## Solving Problems

- Now we have a problem and data, all we need to do is to solve the problem.
- Techniques for solving problems depend on your skill set/background and the problem itself, however I will quickly suggest some simple general techniques.
- Before we see these techniques, let me suggest you avoid complex solutions. This is because complex solutions...
  - …are less likely to generalize to datasets.
  - …are much easer to overfit with.
  - …are harder to explain well.
  - …are difficult to reproduce by others.
  - …are less likely to be cited.

---

## Unjustified Complexity I

From a recent paper:

> This forecasting model integrates a case based reasoning (CBR) technique, a Fuzzy Decision Tree (FDT), and Genetic Algorithms (GA) to construct a decision-making system based on historical data and technical indexes.

- Even if you believe the results. Did the improvement come from the CBR, the FDT, the GA, or from the combination of two things, or the combination of all three?
- In total, there are more than 15 parameters…
- How reproducible do you think this is?

---

## Unjustified Complexity II

- There may be problems that really require very complex solutions, but they seem rare. see [a].
- Your paper is implicitly claiming "this is the simplest way to get results this good".
- Make that claim explicit, and carefully justify the complexity of your approach.

[a] R.C. Holte, Very simple classification rules perform well on most commonly used datasets, Machine Learning 11 (1) (1993). This paper shows that one-level decision trees do very well most of the time.
J. Shieh and E. Keogh iSAX: Indexing and Mining Terabyte Sized Time Series. SIGKDD 2008. This paper shows that the simple Euclidean distance is competitive to much more complex distance measures, once the datasets are reasonably large.

---

## Unjustified Complexity III

> Paradoxically and wrongly, sometimes if the paper used an excessively complicated algorithm, it is more likely that it would be accepted
> — Charles Elkan

If your idea is simple, don't try to hid that fact with unnecessary padding (although unfortunately, that does seem to work sometimes). Instead, sell the simplicity.

> "…it reinforces our claim that our methods are very simple to implement.. ..Before explaining our simple solution this problem……we can objectively discover the anomaly using the simple algorithm…" SIGKDD04

Simplicity is a strength, not a weakness, acknowledge it and claim it as an advantage.

---

## Solving Research Problems

We don't have time to look at all ways of solving problems, so lets just look at two examples in detail.

- Problem Relaxation:
- Looking to other Fields for Solutions:

> If there is a problem you can't solve, then there is an easier problem you can solve: find it.
> — George Polya

Can you find a problem analogous to your problem and solve that?
Can you vary or change your problem to create a new problem (or set of problems) whose solution(s) will help you solve your original problem?
Can you find a subproblem or side problem whose solution will help you solve your problem?
Can you find a problem related to yours that has been solved and use it to solve your problem?
Can you decompose the problem and "recombine its elements in some new manner"? (Divide and conquer)
Can you solve your problem by deriving a generalization from some examples?
Can you find a problem more general than your problem?
Can you start with the goal and work backwards to something you already know?
Can you draw a picture of the problem?
Can you find a problem more specialized?

---

## Problem Relaxation

If you cannot solve the problem, make it easier and then try to solve the easy version.

- If you can solve the easier problem… Publish it if it is worthy, then revisit the original problem to see if what you have learned helps.
- If you cannot solve the easier problem…Make it even easier and try again.

Example: Suppose you want to maintain the closest pair of real-valued points in a sliding window over a stream, in worst-case linear time and in constant space¹. Suppose you find you cannot make progress on this…

Could you solve it if you..
- Relax to amortized instead of worst-case linear time.
- Assume the data is discrete, instead of real.
- Assume you have infinite space.
- Assume that there can never be ties.

¹ I am not suggesting this is an meaningful problem to work on, it is just a teaching example

---

## Problem Relaxation: Concrete example, petroglyph mining

I want to build a tool that can find and extract petroglyphs from an image, quickly search for similar ones, do classification and clustering etc

Bighorn Sheep Petroglyph
Click here for pictures of similar petroglyphs.
Click here for similar images within walking distance.

The extraction and segmentation is really hard, for example the cracks in the rock are extracted as features. I need to be scale, offset, and rotation invariant, but rotation invariance is really hard to achieve in this domain.

What should I do? (continued next slide)

---

## Problem Relaxation: Concrete example, petroglyph mining

- Let us relax the difficult segmentation and extraction problem, after all, there are thousands of segmented petroglyphs online in old books…
- Let us relax rotation invariance problem, after all, for some objects (people, animals) the orientation is usually fixed.
- Given the relaxed version of the problem, can we make progress? Yes! Is it worth publishing? Yes!
- Note that I am not saying we should give up now. We should still tried to solve the harder problem. What we have learned solving the easier version might help when we revisit it.
- In the meantime, we have a paper and a little more confidence.

Note that we must acknowledge the assumptions/limitations in the paper — SIGKDD 2009

---

## Looking to other Fields for Solutions: Concrete example, Finding Repeated Patterns in Time Series

- In 2002 I became interested in the idea of finding repeated patterns in time series, which is a computationally demanding problem.
- After making no progress on the problem, I started to look to other fields, in particular computational biology, which has a similar problem of DNA motifs..
- As happens Tompa & Buhler had just published a clever algorithm for DNA motif finding. We adapted their idea for time series, and published in SIGKDD 2002…

Tompa, M. & Buhler, J. (2001). Finding motifs using random projections. 5th Int'l Conference on Computational Molecular Biology. pp 67-74.

---

## Looking to other Fields for Solutions

You never can tell were good ideas will come from. The solution to a problem on anytime classification came from looking at bee foraging strategies.

Bumblebees can choose wisely or rapidly, but not both at once.. Lars Chittka, Adrian G. Dyer, Fiola Bock, Anna Dornhaus, Nature Vol.424, 24 Jul 2003, p.388

- We data miners can often be inspired by biologists, data compression experts, information retrieval experts, cartographers, biometricians, code breakers etc.
- Read widely, give talks about your problems (not solutions), collaborate, and ask for advice (on blogs, newsgroups etc)

---

## Eliminate Simple Ideas

When trying to solve a problem, you should begin by eliminating simple ideas. There are two reasons why:

- It may be the case that that simple ideas really work very well, this happens much more often than you might think.

- Your paper is making the implicit claim "This is the simplest way to get results this good". You need to convince the reviewer that this is true, to do this, start by convincing yourself.

---

## Eliminate Simple Ideas: Case Study I (a)

In 2009 I was approached by a group to work on the classification of crop types in Central Valley California using Landsat satellite imagery to support pesticide exposure assessment in disease.

They came to me because they could not get DTW to work well..

At first glance this is a dream problem
- Important domain
- Different amounts of variability in each class
- I could see the need to invent a mechanism to allow Partial Rotation Invariant Dynamic Time Warping (I could almost smell the best paper award!)

But there is a problem….

[Figure: Vegetation greenness measure showing Tomato and Cotton time series]

---

## Eliminate Simple Ideas: Case Study I (b)

It is possible to get perfect accuracy with a single line of matlab!

In particular this line: sum(x) > 2700

Lesson Learned: Sometimes really simple ideas work very well. They might be more difficult or impossible to publish, but oh well.

We should always be thinking in the back of our minds, is there a simpler way to do this?

When writing, we must convince the reviewer: This is the simplest way to get results this good

```
>> sum(x)
ans = 2845    2843    2734    2831    2875    2625    2642    2642    2490    2525

>> sum(x) > 2700
ans = 1    1    1    1    1    0    0    0    0    0
```

---

## Eliminate Simple Ideas: Case Study II

A paper sent to SIGMOD 4 or 5 years ago tackled the problem of Generating the Most Typical Time Series in a Large Collection.

The paper used a complex method using wavelets, transition probabilities, multi-resolution properties etc.

The quality of the most typical time series was measured by comparing it to every time series in the collection, and the smaller the average distance to everything, the better.

| SIGMOD Submission paper algorithm | Reviewers algorithm |
|---|---|
| (a few hundred lines of code, learns model from data) | (does not look at the data, and takes exactly one line of code) |
| … X = DWT(A + somefun(B)) Typical_Time_Series = X + Z | Typical_Time_Series = zeros(64) |

Under their metric of success, it is clear to the reviewer (without doing any experiments) that a constant line is the optimal answer for any dataset!

We should always be thinking in the back of our minds, is there a simpler way to do this?
When writing, we must convince the reviewer: This is the simplest way to get results this good

---

## The Importance of being Cynical

In 1515 Albrecht Dürer drew a Rhino from a sketch and written description. The drawing is remarkably accurate, except that there is a spurious horn on the shoulder.

This extra horn appears on every European reproduction of a Rhino for the next 300 years.

Dürer's Rhinoceros (1515)

---

## It Ain't Necessarily So

- Not every statement in the literature is true.
- Implications of this:
  - Research opportunities exist, confirming or refuting "known facts" (or more likely, investigating under what conditions they are true)
  - We must be careful not to assume that it is not worth trying X, since X is "known" not to work, or Y is "known" to be better than X
- In the next few slides we will see some examples

> If you would be a real seeker after truth, it is necessary that you doubt, as far as possible, all things.

---

## Euclidean Distance and Brittleness

- In KDD 2000 I said "Euclidean distance can be an extremely brittle distance measure" Please note the "can"!
- This has been taken as gospel by many researchers
  - However, Euclidean distance can be an extremely brittle.. Xiao et al. 04
  - it is an extremely brittle distance measure…Yu et al. 07
  - The Euclidean distance, yields a brittle metric.. Adams et al 04
  - to overcome the brittleness of the Euclidean distance measure… Wu 04
  - Therefore, Euclidean distance is a brittle distance measure Santosh 07
  - that the Euclidean distance is a very brittle distance measure Tuzcu 04

Is this really true?

Based on comparisons to 12 state-of-the-art measures on 40 different datasets, it is true on some small datasets, but there is no published evidence it is true on any large dataset (Ding et al VLDB 08)

True for some small datasets. Almost certainly not true for any large dataset.

---

## A SIGMOD Best Paper says..

> Our empirical results indicate that Chebyshev approximation can deliver a 3- to 5-fold reduction on the dimensionality of the index space. For instance, it only takes 4 to 6 Chebyshev coefficients to deliver the same pruning power produced by 20 APCA coefficients

Is this really true?
No, actually Chebyshev approximation is slightly worse that other techniques (Ding et al VLDB 08)

The good results were due to a coding bug..

> ..Thus it is clear that the C++ version contained a bug. We apologize for any inconvenience caused (note on authors page)

This is a problem, because many researchers have assumed it is true, and used Chebyshev polynomials without even considering other techniques. For example..

> (we use Chebyshev polynomial approximation) because it is very accurate, and incurs low storage, which has proven very useful for similarity search. Ni and Ravishankar 07

In most cases, do not assume the problem is solved, or that algorithm X is the best, just because someone claims this.

---

## A SIGKDD (r-up) Best Paper says..

(my paraphrasing) You can slide a window across a time series, place all exacted subsequences in a matrix, and then cluster them with K-means. The resulting cluster centers then represent the typical patterns in that time series.

Is this really true?
No, if you cluster the data as described above the output is independent of the input (random number generators are the only algorithms that are supposed to have this property).
The first paper to point this out (Keogh et al 2003) met with tremendous resistance at first, but has been since confirmed in dozens of papers.

This is a problem, dozens of people wrote papers on making it faster/better, without realizing it does not work at all! At least two groups published multiple papers on this:
- Exploiting efficient parallelism for mining rules in time series data. Sarker et al 05
- Parallel Algorithms for Mining Association Rules in Time Series Data. Sarker et al 03
- Mining Association Rules from Multi-stream Time Series Data on Multiprocessor Systems. Sarker et al 05
- Efficient Parallelism for Mining Sequential Rules in Time Series. Sarker et al 06
- Parallel Mining of Sequential Rules from Temporal Multi-Stream Time Series Data. Sarker et al 06

In most cases, do not assume the problem is solved, or that algorithm X is the best, just because someone claims this.

---

## Miscellaneous Examples

Voodoo Correlations in Social Neuroscience. Vul, E, Harris, C, Winkielman, P & Pashler, H.. Perspectives on Psychological Science. Here social neuroscientists criticized for overstating links between brain activity and emotion. This is an wonderful paper.

Why most Published Research Findings are False. J.P. Ioannidis. PLoS Med 2 (2005), p. e124.

Publication Bias: The "File-Drawer Problem" in Scientific Inference. Scargle, J. D. (2000), Journal for Scientific Exploration 14 (1): 91–106

Classifier Technology and the Illusion of Progress. Hand, D. J. Statistical Science 2006, Vol. 21, No. 1, 1-15

Everything you know about Dynamic Time Warping is Wrong. Ratanamahatana, C. A. and Keogh. E. (2004). TDM 04

Magical thinking in data mining: lessons from CoIL challenge 2000. Charles Elkan

How Many Scientists Fabricate and Falsify Research? A Systematic Review and Meta-Analysis of Survey Data. Fanelli D, 2009 PLoS ONE4(5)

---

## Non-Existent Problems

A final point before break.

It is important that the problem you are working on is a real problem.

It may be hard to believe, but many people attempt (and occasionally succeed) to publish papers on problems that don't exist!

Lets us quickly spend 6 slides to see an example.

---

## Solving problems that don't exist I

- This picture shows the visual intuition of the Euclidean distance between two time series of the same length

D(Q,C)

- Suppose the time series are of different lengths?

- We can just make one shorter or the other one longer..

`C_new = resample(C, length(Q), length(C))` — It takes one line of matlab code

---

## Solving problems that don't exist II

But more than 2 dozen group have claimed that this is "wrong" for some reason, and written papers on how to compare two time series of different lengths (without simply making them the same length)

- "(we need to be able) handle sequences of different lengths" PODS 2005
- "(we need to be able to find) sequences with similar patterns to be found even when they are of different lengths" Information Systems 2004
- "(our method) can be used to measure similarity between sequences of different lengths" IDEAS2003

---

## Solving problems that don't exist III

But an extensive literature search (by me), through more than 500 papers dating back to the 1960's failed to produce any theoretical or empirical results to suggest that simply making the sequences have the same length has any detrimental effect in classification, clustering, query by content or any other application.

Let us test this!

---

## Solving problems that don't exist IIII

For all publicly available time series datasets which have naturally different lengths, let us compare the 1-nearest neighbor classification rate in two ways:

- After simply re-normalizing lengths (one line of matlab, no parameters)

- Using the ideas introduced in these papers to support different length comparisons (various complicated ideas, some parameters to tweak) We tested the four most referenced ideas, and only report the best of the four.

---

## Solving problems that don't exist V

The FACE, LEAF, ASL and TRACE datasets are the only publicly available classification datasets that come in different lengths, lets try all of them

| Dataset | Resample to same length | Working with different lengths |
|---------|------------------------|-------------------------------|
| Trace   | 0.00                   | 0.00                          |
| Leaves  | 4.01                   | 4.07                          |
| ASL     | 14.3                   | 14.3                          |
| Face    | 2.68                   | 2.68                          |

A two-tailed t-test with 0.05 significance level for each dataset indicates that there is no statistically significant difference between the accuracy of the two sets of experiments.

---

## Solving problems that don't exist VI

A least two dozen groups assumed that comparing different length sequences was a non-trivial problem worthy of research and publication.

But there was and still is to this day, zero evidence to support this!

And there is strong evidence to suggest this is not true.

There are two implications of this:
- Make sure the problem you are solving exists!
- Make sure you convince the reviewer it exists.

---

## Coffee Break

---

## Part II of How to do good research, get it published in SIGKDD and get it cited

Eamonn Keogh

---

## Writing the Paper

> There are three rules for writing the novel…
>
> ..Unfortunately, no one knows what they are.
> — W. Somerset Maugham

---

## Writing the Paper

- Make a working title
- Introduce the topic and define (informally at this stage) terminology
- Motivation: Emphasize why is the topic important
- Relate to current knowledge: what's been done
- Indicate the gap: what need's to be done?
- Formally pose research questions
- Explain any necessary background material.
- Introduce formal definitions.
- Introduce your novel algorithm/representation/data structure etc.
- Describe experimental set-up, explain what the experiments will show
- Describe the datasets
- Summarize results with figures/tables
- Discuss results
- Explain conflicting results, unexpected findings and discrepancies with other research
- State limitations of the study
- State importance of findings
- Announce directions for further research
- Acknowledgements
- References

> What is written without effort is in general read without pleasure
> — Samuel Johnson

Adapted from Hengl, T. and Gould, M., 2002. Rules of thumb for writing research articles.

---

## A Useful Principle

Steve Krug has a wonderful book about web design, which also has some useful ideas for writing papers.

A fundamental principle is captured in the title:
**Don't make the reviewer of your paper think!**

1) If they are forced to think, they may resent being forced to make the effort. The are literally not being paid to think.
2) If you let the reader think, they may think wrong!

With very careful writing, great organization, and self explaining figures, you can (and should) remove most of the effort for the reviewer

---

## A Useful Principle

A simple concrete example:

This requires a lot of thought to see that 2DDW is better than Euclidian distance

This does not

Figure 3: Two pairs of faces clustered using 2DDW (top) and Euclidean distance (bottom)

---

## Keogh's Maxim

I firmly believe in the following:

**If you can save the reviewer one minute of their time, by spending one extra hour of your time, then you have an obligation to do so.**

---

## Keogh's Maxim can be derived from first principles

- The author sends about one paper to SIGKDD
- The reviewer must review about ten papers for SIGKDD

- The benefit for the author in getting a paper into SIGKDD is hard to quantify, but could be tens of thousands of dollars (if you get tenure, if you get that job in Google…).
- The benefit for a reviewer is close to zero, they don't get paid.

Therefore: The author has the responsibly to do all the work to make the reviewers task as easy as possible.

> Remember, each report was prepared without charge by someone whose time you could not buy
> — Alan Jay Smith

A. J. Smith, "The task of the referee" IEEE Computer, vol. 23, no. 4, pp. 65-71, April 1990.

---

## An example of Keogh's Maxim

- We wrote a paper for SIGKDD 2009
- Our mock reviewers had a hard time understanding a step, where a template must be rotated. They all eventually got it, it just took them some effort.
- We rewrote some of the text, and added in a figure that explicitly shows the template been rotated
- We retested the section on the same, and new mock reviewers, it worked much better.
- We spent 2 or 3 hours to save the reviewers tens of seconds.

---

## Anchoring

> I have often said reviewers make an initial impression on the first page and don't change 80% of the time
> — Mike Pazzani

This idea, that first impressions tend to be hard to change, has a formal name in psychology, Anchoring.

---

## Others have claimed that Anchoring is used by reviewers

— Xindong Wu

---

## Anchoring and Reviewing

Another strategy people seem to use intuitively and unconsciously to simplify the task of making judgments is called anchoring. Some natural starting point is used as a first approximation to the desired judgment. This starting point is then adjusted, based on the results of additional information or analysis. Typically, however, the starting point serves as an anchor that reduces the amount of adjustment, so the final estimate remains closer to the starting point than it ought to be.
— Richards J. Heuer, Jr. Psychology of Intelligence Analysis (CIA)

What might be the "natural starting point" for a SIGKDD reviewer making a judgment on your paper?
Hopefully it is not the author or institution: "people from CMU tend to do good work, lets have a look at this…", "This guys last paper was junk.."

I believe that the title, abstract and introduction form an anchor. If these are excellent, then the reviewer reads on assuming this is a good paper, and she is looking for things to confirm this.

However, if they are poor, the reviewer is just going to scan the paper to confirm what she already knows, "this is junk"

I don't have any studies to support this for reviewing papers. I am making this claim based on my experience and feedback (The title is the most important part of the paper. Jeff Scargle). However there are dozens of studies to support the idea of anchoring when people make judgments about buying cars, stocks, personal injury amounts in court cases etc.

---

## The First Page as an Anchor

The introduction acts as an anchor. By the end of the introduction the reviewer must know.

- What is the problem?
- Why is it interesting and important?
- Why is it hard? why do naive approaches fail?
- Why hasn't it been solved before? (Or, what's wrong with previous proposed solutions?)
- What are the key components of my approach and results? Also include any specific limitations.
- A final paragraph or subsection: "Summary of Contributions". It should list the major contributions in bullet form, mentioning in which sections they can be found. This material doubles as an outline of the rest of the paper, saving space and eliminating redundancy.

This advice is taken almost verbatim from Jennifer.

> If possible, an interesting figure on the first page helps
> — Jennifer Windom

---

## Reproducibility

Reproducibility is one of the main principles of the scientific method, and refers to the ability of a test or experiment to be accurately reproduced, or replicated, by someone else working independently.

---

## Reproducibility

- In a "bake-off" paper Veltkamp and Latecki attempted to reproduce the accuracy claims of 15 shape matching papers but discovered to their dismay that they could not match the claimed accuracy for any approach.
- A recent paper in VLDB showed a similar thing for time series distance measures.

> The vast body of results being generated by current computational science practice suffer a large and growing credibility gap: it is impossible to believe most of the computational results shown in conferences and papers
> — David Donoho

Properties and Performance of Shape Similarity Measures. Remco C. Veltkamp and Longin Jan Latecki. IFCS 2006
Querying and Mining of Time Series Data: Experimental Comparison of Representations and Distance Measures. Ding, Trajcevski, Scheuermann, Wang & Keogh. VLDB 2008
Fifteen Years of Reproducible Research in Computational Harmonic Analysis- Donoho et al.

---

## Two Types of Non-Reproducibility

- Explicit: The authors don't give you the data, or they don't tell you the parameter settings.

- Implicit: The work is so complex that it would take you weeks to attempts to reproduce the results, or you are forced to buy expensive software/hardware/data to attempt reproduction.
  Or, the authors do give distribute data/code, but it is not annotated or is so complex as to be an unnecessary large burden to work with.

---

## Explicit Non Reproducibility

We approximated collections of time series, using algorithms AgglomerativeHistogram and FixedWindowHistogram and utilized the techniques of Keogh et.al., in the problem of querying collections of time series based on similarity. Our results, indicate that the histogram approximations resulting from our algorithms are far superior than those resulting from the APCA algorithm of Keogh et.al., The superior quality of our histograms is reflected in these problems by reducing the number of false positives during time series similarity indexing, while remaining competitive in terms of the time required to approximate the time series.

This paper appeared in ICDE02. The "experiment" is shown in its entirety, there are no extra figures or details.

- Which collections?? How large? What kind of data?
- How are the queries selected?
- What results??
- superior by how much?, as measured how?
- How competitive?, as measured how?

---

## (Pavarotti parody of Explicit Non Reproducibility)

We approximated collections of time series, using algorithms AgglomerativeHistogram and FixedWindowHistogram and utilized the techniques of Keogh et.al., in the problem of querying collections of time series based on similarity. Our results, indicate that the histogram approximations resulting from our algorithms are far superior than those resulting from the APCA algorithm of Keogh et.al., The superior quality of our histograms is reflected in these problems by reducing the number of false positives during time series similarity indexing, while remaining competitive in terms of the time required to approximate the time series.

I got a collection of opera arias as sung by Luciano Pavarotti, I compared his recordings to my own renditions of the songs. My results, indicate that my performances are far superior to those by Pavarotti. The superior quality of my performance is reflected in my mastery of the highest notes of a tenor's range, while remaining competitive in terms of the time required to prepare for a performance.

---

## Implicit Non Reproducibility

From a recent paper:

> This forecasting model integrates a case based reasoning (CBR) technique, a Fuzzy Decision Tree (FDT), and Genetic Algorithms (GA) to construct a decision-making system based on historical data and technical indexes.

- In order to begin reproduce this work, we have to implement a Case Based Reasoning System and a Fuzzy Decision Tree and a Genetic Algorithm.
- With rare exceptions, people don't spend a month reproducing someone else's results, so this is effectively non-reproducible.
- Note that it is not the extraordinary complexity of the work that makes this non-reproducible (although it does not help), if the authors had put free high quality code and data online…

---

## Why Reproducibility?

- We could talk about reproducibility as the cornerstone of scientific method and an obligation to the community, to your funders etc. However this tutorial is about getting papers published.
- Having highly reproducible research will greatly help your chances of getting your paper accepted.
- Explicit efforts in reproducibility instill confidence in the reviewers that your work is correct.
- Explicit efforts in reproducibility will give the (true) appearance of value.

As a bonus, reproducibility will increase your number of citations.

---

## How to Ensure Reproducibility

- Explicitly state all parameters and settings in your paper.
- Build a webpage with annotated data and code and point to it
  (Use an anonymous hosting service if necessary for double blind reviewing)

- It is too easy to fool yourself into thinking your work is reproducible when it is not. Someone other than you should test the reproducibly of the paper.

For blind review conferences, you can create a Gmail account, place all data there, and put the account info in the paper.

---

## How to Ensure Reproducibility

In the next few slides I will quickly dismiss commonly heard objections to reproducible research (with thanks to David Donoho)

- I can't share my data for privacy reasons.
- Reproducibility takes too much time and effort.
- Strangers will use your code/data to compete with you.
- No one else does it. I won't get any credit for it.

---

## But I can't share my data for privacy reasons…

- My first reaction when I see this is to think it may not be true. If you a going to claim this, prove it.

- Can you also get a dataset that you can release?

- Can you make a dataset that you can publicly release, which is about the same size, cardinality, distribution as the private dataset, then test on both in you paper, and release the synthetic one?

---

## Reproducibility takes too much time and effort

- First of all, this has not been my personal experience.
- Reproducibility can save time. When your conference paper gets invited to a journal a year later, and you need to do more experiments, you will find it much easier to pick up were you left off.
- Forcing grad students/collaborators to do reproducible research makes them much easier to work with.

---

## Strangers will use your code/data to compete with you

- But competition means "strangers will read your papers and try to learn from them and try to do even better". If you prefer obscurity, why are you publishing?
- Other people using your code/data is something that funding agencies and tenure committees love to see.

Sometimes the competition is undone by their carelessness. Below (center) is a figure from a paper that uses my publicly available datasets. The alleged shapes in their paper are clearly not the real shapes (confusion of Cartesian and polar coordinates?). This is good example of the importance of the "Send preview to the rival authors". This would have avoided publishing such an embarrassing mistake.

Alleged Arrowhead and Diatoms

Actual Arrowhead — Actual Diatoms

---

## No one else does it. I won't get any credit for it

- It is true that not everyone does it, but that just means that you have a way to stand above the competition.
- A review of my SIGKDD 2004 paper said (my paraphrasing, I have lost the original email).

> The results seem to good to be true, but I had my grad student download the code and data and check the results, it really does work as well as they claim.

---

## Parameters (are bad)

- The most common cause of Implicit Non Reproducibility is a algorithm with many parameters.
- Parameter-laden algorithms can seem (and often are) ad-hoc and brittle.
- Parameter-laden algorithms decrease reviewer confidence.
- For every parameter in your method, you must show, by logic, reason or experiment, that either…
  - There is some way to set a good value for the parameter.
  - The exact value of the parameter makes little difference.

> With four parameters I can fit an elephant, and with five I can make him wiggle his trunk
> — John von Neumann

---

## Unjustified Choices (are bad)

- It is important to explain/justify every choice, even if it was an arbitrary choice.
- For example, this line frustrated me: Of the 300 users with enough number of sessions within the year, we randomly picked 100 users to study. Why 100? Would we have gotten similar results with 200?
- Bad: We used single linkage clustering...Why single linkage, why not group average or Wards?
- Good: We experimented with single/group/complete linkage, but found this choice made little difference, we therefore report only…
- Better: We experimented with single/group/complete linkage, but found this choice little difference, we therefore report only single linkage in this paper, however the interested reader can view the tech report [a] to see all variants of clustering.

---

## Important Words/Phrases I

- Optimal: Does not mean "very good"
  - We picked the optimal value for X... No! (unless you can prove it)
  - We picked a value for X that produced the best..
- Proved: Does not mean "demonstrated"
  - With experiments we proved that our.. No! (experiments rarely prove things)
  - With experiments we offer evidence that our..
- Significant: There is a danger of confusing the informal statement and the statistical claim
  - Our idea is significantly better than Smiths
  - Our idea is statistically significantly better than Smiths, at a confidence level of…

---

## Important Words/Phrases II

- Complexity: Has an overloaded meaning in computer science
  - The X algorithms complexity means it is not a good solution (complex= intricate)
  - The X algorithms time complexity is O(n6) meaning it is not a good solution
- It is easy to see: First, this is a cliché. Second, are you sure it is easy?
  - It is easy to see that P = NP
- Actual: Almost always has no meaning in a sentence
  - It is an actual B-tree -> It is a B-tree
  - There are actually 5 ways to hash a string -> There are 5 ways to hash a string
- Theoretically: Almost always has no meaning in a sentence
  - Theoretically we could have jam or jelly on our toast.
- etc: Only use it if the remaining items on the list are obvious.
  - We named the buckets for the 7 colors of the rainbow, red, orange, yellow etc.
  - We measure performance factors such as stability, scalability, etc.    No!

---

## Important Words/Phrases III

- Correlated: In informal speech it is a synonym for "related"
  - Celsius and Fahrenheit are correlated. (clearly correct, perfect linear correlation)
  - The tightness of lower bounds is correlated with pruning power. No!
- (Data) Mined
  - Don't say "We mined the data…", if you can say "We clustered the data.." or "We classified the data…" etc

---

## Important Words/Phrases IIII

- In this paper: Where else? We are reading this paper

From a single SIGMOD paper:

- In this paper, we attempt to approximate..
- Thus, in this paper, we explore how to use..
- In this paper, our focus is on indexing large collections..
- In this paper, we seek to approximate and index..
- Thus, in this paper, we explore how to use the..
- The indexing proposed in this paper belongs to the class of..
- Figure 1 summarizes all the symbols used in this paper…
- In this paper, we use Euclidean distance..
- The results to be presented in this paper do not..
- A key result to be proven later in this paper is that the..
- In this paper, we adopt the Euclidean distance function..
- In this paper we explore how to apply

---

## DABTAU — Define Acronyms Before They Are Used

DHT is used and again and again and again and again and again and again

DHT is finally defined!

It is very important that you DABTAU or your readers may be confused.
(Define Acronyms Before They Are Used)

But anyone that reviews for this conference will surely know what the acronym means!
Don't be so sure, your reviewer may be a first-year, non-native English-speaking grad student that got 15 papers dumped on his desk 3 days before the reviewing deadline.

You can only assume this for acronyms where we have forgotten the original words, like laser, radar, Scuba. Remember our principle, don't make the reviewer think.

---

## Use all the Space Available

Some reviewer is going to look at this empty space and say..

- They could have had an additional experiment
- They could have had more discussion of related work
- They could have referenced more of my papers
- etc

The best way to write a great 9 page paper, is to write a good 12 or 13 page paper and carefully pare it down.

---

## You can use Color in the Text

In the example to the right, color helps emphasize that the order in which bits are added/removed to a representation.

In the example below, color links numbers in the text with numbers in a figure.

Bear in mind that the reader may not see the color version, so you cannot rely on color.

SIGKDD 2008

People have been using color this way for well over a 1,000 years

SIGKDD 2009

---

## Avoid Weak Language I

Compare

> ..with a dynamic series, it might fail to give accurate results.

With..

> ..with a dynamic series, it has been shown by [7] to give inaccurate results. (give a concrete reference)

Or..

> ..with a dynamic series, it will give inaccurate results, as we show in Section 7. (show me numbers)

---

## Avoid Weak Language II

Compare

> In this paper, we attempt to approximate and index a d-dimensional spatio-temporal trajectory..

With…

> In this paper, we approximate and index a d-dimensional spatio-temporal trajectory..

Or…

> In this paper, we show, for the first time, how to approximate and index a d-dimensional spatio-temporal trajectory..

---

## Avoid Weak Language III

> The paper is aiming to detect and retrieve videos of the same scene…

Are you aiming at doing this, or have you done it? Why not say…

> In this work, we introduce a novel algorithm to detect and retrieve videos..

> The DTW algorithm tries to find the path, minimizing the cost..

The DTW does not try to do this, it does this.

> The DTW algorithm finds the path, minimizing the cost..

> Monitoring aggregate queries in real-time over distributed streaming environments appears to be a great challenge.

Appears to be, or is? Why not say…

> Monitoring aggregate queries in real-time over distributed streaming environments is known to be a great challenge [1,2].

---

## Avoid Overstating

Don't say:

> We have shown our algorithm is better than a decision tree.

If you really mean…

> We have shown our algorithm can be better than decision trees, when the data is correlated.

Or..

> On the Iris and Stock dataset, we have shown that our algorithm is more accurate, in future work we plan to discover the conditions under which our...

---

## Use the Active Voice

| Passive | Active |
|---------|--------|
| It can be seen that… | We can see that… |
| "seen" by whom? | |
| Experiments were conducted… | We conducted experiments... |
| | Take responsibility |
| The data was collected by us. | We collected the data. |
| | Active voice is often shorter |

> The active voice is usually more direct and vigorous than the passive
> — William Strunk, Jr

---

## Avoid Implicit Pointers

Consider the following sentence:

> "We used DFT. It has circular convolution property but not the unique eigenvectors property. This allows us to…"

What does the "This" refer to?
- The use of DFT?
- The convolution property?
- The unique eigenvectors property?

Check every occurrence of the words "it", "this", "these" etc. Are they used in an unambiguous way?

> Avoid nonreferential use of "this", "that", "these", "it", and so on.
> — Jeffrey D. Ullman

---

## Many papers read like this: We invented a new problem, and guess what, we can solve it!

This paper proposes a new trajectory clustering scheme for objects moving on road networks. A trajectory on road networks can be defined as a sequence of road segments a moving object has passed by. We first propose a similarity measurement scheme that judges the degree of similarity by considering the total length of matched road segments. Then, we propose a new clustering algorithm based on such similarity measurement criteria by modifying and adjusting the FastMap and hierarchical clustering schemes. To evaluate the performance of the proposed clustering scheme, we also develop a trajectory generator considering the fact that most objects tend to move from the starting point to the destination point along their shortest path. The performance result shows that our scheme has the accuracy of over 95%.

When the authors invent the definition of the data, and they invent the problem, and they invent the error metric, and they make their own data, can we be surprised if they have high accuracy?

---

## Motivating your Work

If there is a different way to solve your problem, and you do not address this, your reviewers might think you are hiding something.

You should very explicitly say why the other ideas will not work. Even if it is obvious to you, it might not be obvious to the reviewer.

Another way to handle this might be to simply code up the other way and compare to it.

---

## Motivation

For reasons I don't understand, SIGKDD papers rarely quote other papers. Quoting other papers can allow the writing of more forceful arguments…

This is much better than.. Paper [20] notes that rotation is hard to deal with.

This is much better than.. That paper says time warping is too slow.

---

## Motivation

Martin Wattenberg had a beautiful paper in InfoVis 2002 that showed the repeated structure in strings…

Bach, Goldberg Variations

If I had reviewed it, I would have rejected it, noting it had already been done, in 1120!

It is very important to convince the reviewers that your work is original.

- Do a detailed literature search.
- Use mock reviewers.
- Explain why your work is different (see Avoid "Laundry List" Citations)

De Musica: Leaf from Boethius' treatise on music. Diagram is decorated with the animal form of a beast. Alexander Turnbull Library, Wellington, New Zealand

---

## Avoid "Laundry List" Citations I

In some of my early papers, I misspelled Davood Rafiei's name Refiei. This spelling mistake now shows up in dozens of papers by others…

- Finding Similarity in Time Series Data by Method of Time Weighted ..
- Similarity Search in Time Series Databases Using ..
- Financial Time Series Indexing Based on Low Resolution …
- Similarity Search in Time Series Data Using Time Weighted …
- Data Reduction and Noise Filtering for Predicting Times …
- Time Series Data Analysis and Pre-process on Large …
- G probability-based method and its …
- A Review on Time Series Representation for Similarity-based …
- Financial Time Series Indexing Based on Low Resolution …
- A New Design of Multiple Classifier System and its Application to…

This (along with other facts omitted here) suggests that some people copy "classic" references, without having read them.

In other cases I have seen papers that claim "we introduce a novel algorithm X", when in fact an essentially identical algorithm appears in one of the papers they have referenced (but probably not read).

Read your references! If what you are doing appears to contradict or duplicate previous work, explicitly address this in your paper.

> A classic is something that everybody wants to have read and nobody wants to read

---

## Avoid "Laundry List" Citations II

One of Carla Brodley's pet peeves is laundry list citations:

> "Paper A says 'blah blah' about Paper B, so in my paper I say the same thing, but cite Paper B, and I did not read Paper B to form my own opinion. (and in some cases did not even read Paper B at all....)"

The problem with this is:
- You look like you are lazy.
- You look like you cannot form your own opinion.
- If paper A is wrong about paper B, and you echo the errors, you look naïve.

> I dislike broad reference bundles such as There has been plenty of related work [a,s,d,f,g,c,h]
> — Claudia Perlich

> Often related work sections are little more than annotated bibliographies.
> — Chris Drummond

---

## A Common Logic Error in Evaluating Algorithms: Part I

Here the authors test the rival algorithm, DTW, which has no parameters, and achieved an error rate of 0.127.

They then test 64 variations of their own approach, and since there exists at least one combination that is lower than 0.127, they claim that their algorithm "performs better"

> "Comparing the error rates of DTW (0.127) and those of Table 3, we observe that XXX performs better"

Note that in this case the error is explicit, because the authors published the table. However in many case the authors just publish the result "we got 0.100", and it is less clear that the problem exists.

Table 3: Error rates using XXX on time series histograms with equal bin size

---

## A Common Logic Error in Evaluating Algorithms: Part II

To see why this is a flaw, consider this:

- We want to find the fastest 100m runner, between India and China.
- India does a set of trails, finds its best man, Anil, and Anil turns up expecting a race.
- China ask Joe to run by himself. Although mystified, he obliging does so, and clocks 9.75 seconds.
- China then tells all 1.4 billion Chinese people to run 100m.
- The best of all 1.4 billion runs was Jin, who clocked 9.70 seconds.
- China declares itself the winner!

Is this fair? Of course not, but this is exactly what the previous slide does.

> Keep in mind that you should never look at the test set. This may sound obvious, but I cannot longer count the number of papers that I had to reject because of this.
> — Johannes Fuernkranz

---

## Always put some variance estimate on performance measures

(do everything 10 times and give me the variance of whatever you are reporting)

— Claudia Perlich

Suppose I want to know if Euclidean distance or L1 distance is best on the CBF problem (with 150 objects), using 1NN…

| | Bad: Do one test | A little better: Do 50 tests, and report mean | Better: Do 50 tests, report mean and variance | Much Better: Do 50 tests, report confidence |
|---|---|---|---|---|

---

## Variance Estimate on Performance Measures

Suppose I want to know if American males are taller than Chinese males. I randomly sample 16 of each, although it happens that I get Yao Ming in the sample…

Plotting just the mean heights is very deceptive here.

| | China | US |
|---|---|---|
| Mean | 175.74 | 173.00 |
| STD | 16.15 | 6.45 |

---

## Be fair to the Strawmen/Rivals

In a KDD paper, this figure is the main proof of utility for a new idea. A query is suppose to match to location 250 in the target sequence. Their approach does, Euclidean distance does not….

SHMM (larger is better match) — Euclidean Distance (Smaller is better match)

---

## (Strawmen/Rivals continued)

The authors would NOT share this data, citing confidentiality (even though the entire dataset is plotted in the paper). So we cannot reproduce their experiments… or can we?

I wrote a program to extract the data from the PDF file…

SHMM (larger is better match) — Euclidean Distance (Smaller is better match)

---

## Be fair to the Strawmen/Rivals

If we simply normalize the data (as dozens of papers explicitly point out) the best match for Euclidean distance is at… location 250!

So this paper introduces a method which is:
1) Very hard to implement
2) Computationally demanding
3) Requires lots of parameters

To do the same job as 2 lines of parameter free code.

Because the experiments are not reproducible, no one has noticed this. Several authors wrote follow-up papers, simply assuming the utility of this work.

---

## Plagiarism

**2006 paper:** Suppose we have two time series X1 and X2, of length t1 and t2 respectively, where: To align two sequences using DTW we construct an t1-by-t2 matrix where the (i-th, jth) element of the matrix contains the distance d(x1i,x2j) between the two points x1i and x2j (With Euclidean distance, d(x1i, x2j) =(x1i− x2j)2 ). Each matrix element (i,j) corresponds to the alignment between the points x1i and x2j. A warping path W, is a contiguous (in the sense stated below) set of matrix elements that defines a mapping between X1 and X2. The k-th element of W is defined as wk = (i, j)k, W = w1,w2, ,wk, ,wK max(t1, t2) ≤ K < m + n − 1. The warping path is typically subject to several constraints. Boundary Conditions: w1 = (1,1) and wK = (t1, t2), simply stated, this requires the warping path to start and finish in diagonally opposite corner cells of the matrix. Continuity: Given wk = (a,b) then wk−1 = (a0, b0) where a−a0 ≤ 1 and b−b0 ≤ 1. This restricts the allowable steps in the warping path to adjacent cells (including diagonally adjacent cells). Monotonicity: Given wk = (a,b) then wk−1 = (a0, b0) where a − a0 ≥ 1 and b − b0 ≥ 0. This forces the points in W to be monotonically spaced in time. There are exponentially many warping paths that satisfy the above conditions, however we are interested only in the path which minimizes the warping cost, The K in the denominator is used to compensate for the fact that warping paths may have different

**1999 paper:** Suppose we have two time series Q and C, of length n and m respectively, where: To align two sequences using DTW we construct an n-by-m matrix where the (ith, jth) element of the matrix contains the distance d(qi,cj) between the two points qi and cj (With Euclidean distance, d(qi,cj) = (qi - cj)2 ). Each matrix element (i,j) corresponds to the alignment between the points qi and cj. A warping path W, is a contiguous (in the sense stated below) set of matrix elements that defines a mapping between Q and C. The kth element of W is defined as wk = (i,j)k so we have: W = w1, w2, …,wk,…,wK max(m,n) K < m+n-1. The warping path is typically subject to several constraints. Boundary Conditions: w1 = (1,1) and wK = (m,n), simply stated, this requires the warping path to start and finish in diagonally opposite corner cells of the matrix. Continuity: Given wk = (a,b) then wk-1 = (a',b') where a–a' 1 and b-b' 1. This restricts the allowable steps in the warping path to adjacent cells (including diagonally adjacent cells). Monotonicity: Given wk = (a,b) then wk-1 = (a',b') where a–a' ³ 0 and b-b' ³ 0. This forces the points in W to be monotonically spaced in time. There are exponentially many warping paths that satisfy the above conditions, however we are interested only in the path which minimizes the warping cost: The K in the denominator is used to compensate for the fact that warping paths may have different

Plagiarism can be obvious..

..or it can be subtle. I think the below is an example of plagiarism, but the 2005 authors do not.

**2005 paper:** As with most data mining problems, data representation is one of the major elements to reach an efficient and effective solution. ... pioneered by Pavlidis et al… refers to the idea of representing a time series of length n using K straight lines

**2001 paper:** As with most computer science problems, representation of the data is the key to efficient and effective solutions.... pioneered by Pavlidis… refers to the approximation of a time series T, of length n, with K straight lines

---

## Figures also get Plagiarized

This particular figure gets stolen a lot.

Here by two medical doctors

Here in a Chinese publication (the author did flip the figure upside down!)

Here in a Portuguese publication..

One page of a ten page paper. All the figures are taken without acknowledgement from Keogh's tutorial

---

## What Happens if you Plagiarize?

The best thing that can happen is the paper gets rejected by a reviewer that spots the problem.

If the paper gets published, there is an excellent chance that the original author will find out, at that point, they own you.

Note to users: Withdrawn Articles in Press are proofs of articles which have been peer reviewed and initially accepted, but have since been withdrawn..

---

## Making Good Figures

- I personally feel that making good figures is very important to a papers chance of acceptance.
- The first thing reviewers often do with a paper is scan through it, so images act as an anchor.
- In some cases a picture really is worth a thousand words.

See papers of Michail Vlachos, it is clear that he agonizes over every detail in his beautiful figures.
See the books of Edward Tufte.
See Stephen Few's books/blog (www.perceptualedge.com)

---

## Poor Figure Example

Fig. 1. Sequence graph example

What's wrong with this figure? Let me count the ways…
None of the arrows line up with the "circles". The "circles" are all different sizes and aspect ratios, the (normally invisible) white bounding box around the numbers breaks the arrows in many places. The figure captions has almost no information. Circles are not aligned…

On the right is my redrawing of the figure with PowerPoint. It took me 300 seconds.

This figure is an insult to reviewers. It says, "we expect you to spend an unpaid hour to review our paper, but we don't think it worthwhile to spend 5 minutes to make clear figures"

---

## Note that there are figures drawn seven hundred years ago that have much better symmetry and layout.

Peter Damian, Paulus Diaconus, and others, Various saints lives: Netherlands, S. or France, N. W.; 2nd quarter of the 13th century

Lets us see some more examples of poor figures, then see some principles that can help

---

## Poor Figures: Space Waste Example 1

This figure wastes 80% of the space it takes up.

In any case, it could be replace by a short English sentence: "We found that for selectivity ranging from 0 to 0.05, the four methods did not differ by more than 5%"

Why did they bother with the legend, since you can't tell the four lines apart anyway?

---

## Poor Figures: Space Waste Example 2

This figure wastes almost a quarter of a page.

The ordering on the X-axis is arbitrary, so the figure could be replaced with the sentence "We found the average performance was 198 with a standard deviation of 11.2".

The paper in question had 5 similar plots, wasting an entire page.

---

## Poor Figures: Space Waste Example 3

The figure below takes up 1/6 of a page, but it only reports 3 numbers.

---

## Poor Figures: Space Waste Example 4

The figure below takes up 1/6 of a page, but it only reports 2 numbers!

Actually, it really only reports one number! Only the relative times really matter, so they could have written "We found that FTW is 1007 times faster than the exact calculation, independent of the sequence length".

---

## Both figures below describe the classification of time series motions…

It is not obvious from this figure which algorithm is best. The caption has almost zero information. You need to read the text very carefully to understand the figure.

Redesign by Keogh:
At a glance we can see that the accuracy is very high. We can also see that DTW tends to win when the...

The data is plotted in Figure 5. Note that any correctly classified motions must appear in the upper left (gray) triangle.

Figure 5. Each of our 100 motions plotted as a point in 2 dimensions. The X value is set to the distance to the nearest neighbor from the same class, and the Y value is set to the distance to the nearest neighbor from any other class.

---

## Both figures below describe the performance of 4 algorithms on indexing of time series of different lengths…

This figure takes 1/2 of a page.

This figure takes 1/6 of a page.

---

## This should be a bar chart, the four items are unrelated

(in any case this should probably be a table, not a figure)

---

## Principles to make Good Figures

- Think about the point you want to make, should it be done with words, a table, or a figure. If a figure, what kind?
- Color helps (but you cannot depend on it)
- Linking helps (sometimes called brushing)
- Direct labeling helps
- Meaningful captions helps
- Minimalism helps (Omit needless elements)
- Finally, taking great care, taking pride in your work, helps

---

## Direct labeling helps

It removes one level of indirection, and allows the figures to be self explaining

(see Edward Tufte: Visual Explanations, Chapter 4)

Figure 10. Stills from a video sequence; the right hand is tracked, and converted into a time series: A) Hand at rest: B) Hand moving above holster. C) Hand moving down to grasp gun. D Hand moving to shoulder level, E) Aiming Gun.

---

## Linking helps interpretability I

How did we get from here

To here?

What is Linking?
Linking is connecting the same data in two views by using the same color (or thickness etc). In the figures below, color links the data in the pie chart, with data in the scatterplot.

It is not clear from the above figure.

See next slide for a suggested fix.

---

## Linking helps interpretability II

In this figure, the color of the arrows inside the fish link to the colors of the arrows on the time series.

This tells us exactly how we go from a shape to a time series.

Note that there are other links, for example in II, you can tell which fish is which based on color or link thickness linking.

Minimalism helps: In this case, numbers on the X-axis do not mean anything, so they are deleted.

---

## Direct labeling helps

- Don't cover the data with the labels! You are implicitly saying "the results are not that important".
- Do we need all the numbers to annotate the X and Y axis?
- Can we remove the text "With Ranking"?

Note that the line thicknesses differ by powers of 2, so even in a B/W printout you can tell the four lines apart.

Minimalism helps: delete the "with Ranking", the X-axis numbers, the grid…

---

## Covering the data with the labels is a common sin

---

## These two images, which are both use to discuss an anomaly detection algorithm, illustrate many of the points discussed in previous slides.

Color helps - Direct labeling helps - Meaningful captions help

The images should be as self contained as possible, to avoid forcing the reader to look back to the text for clarification multiple times.

Note that while Figure 6 use color to highlight the anomaly, it also uses the line thickness (hard to see in PowerPoint) thus this figure works also well in B/W printouts

---

## Thinking about the point you want to make, helps

Figure 3: Two pairs of faces clustered using 2DDW (top) and Euclidean distance (bottom)

From looking at this figure, we are suppose to tell that 2DDW produces more intuitive results than Euclidean Distance.

I have a lot of experience with these types of things, and high motivation, but it still took me 4 or 5 minutes to see this.

Do you think the reviewer will spend that amount of time on a single figure?

Looking at this figure, we can tell that 2DDW produces more intuitive results than Euclidean Distance in 2 or 3 seconds.

Paradoxically, this figure has less information (hierarchical clustering is lossy relative to a distance matrix) but communicates a lot more knowledge.

---

## Contrast these two figures, both of which attempt to show that petroglyphs can be clustered meaningfully.

- Thinking about the…, helps
- Color helps
- Direct labeling helps
- Meaningful captions helps

To figure out the utility of the similarity measures in this paper, you need to look at text and two figures, spanning four pages.

SIGKDD 09

---

## Direct labeling and table redesign

Using the labels "Method1" "Method2" etc, gives a level of indirection. We have to keep referring back to the text (on a different page) to understand the content.

Direct labeling helps

Redesigned by Keogh:

| Length | Sequential Sparsification | Linear Sparsification | Quadratic Sparsification | Wavelet Sparsification | Raw Data |
|--------|--------------------------|----------------------|--------------------------|------------------------|----------|
| 128    | 0.77                     | 0.95                 | 0.95                     | 0.77                   | 0.77     |
| 256    | 0.71                     | 0.95                 | 0.94                     | 0.86                   | 0.74     |
| 512    | 0.66                     | 0.94                 | 0.95                     | 0.94                   | 0.77     |
| Avg    | 0.71                     | 0.95                 | 0.95                     | 0.86                   | 0.76     |

Table 3: Similarity Results for CBF Trials

The four significant digits are ludicrous on a data set with 300 objects.

---

## Spurious Significant Digits

This paper offers 7 significant digits in the results on a dataset a few thousand items

This paper offers 9 significant digits in the results on a dataset a few hundred items

Spurious digits are not just unnecessary, they are a lie! They imply a precision that you do not have. At best they make you look like an amateur.

---

## Pseudo code

As with real code, it is probably better to break very long pseudocode into several shorter units

---

## The most Common Problems with Figures

1. Too many patterns on bars
2. Use of both different symbols and different lines
3. Too many shades of gray on bars
4. Lines too thin (or thick)
5. Use of three-dimensional bars for only two variables
6. Lettering too small and font difficult to read
7. Symbols too small or difficult to distinguish
8. Redundant title printed on graph
9. Use of gray symbols or lines
10. Key outside the graph
11. Unnecessary numbers in the axis
12. Multiple colors map to the same shade of gray
13. Unnecessary shading in background
14. Using bitmap graphics (instead of vector graphics)
15. General carelessness

Eileen K Schofield: Quality of Graphs in Scientific Journals: An Exploratory Study. Science Editor, 25 (2), 39-41

Eamonn Keogh: My Pet Peeves

---

## 1. Too many patterns on bars

Here the problem is compounded by the tiny size of the key. The area of each key-box is about 2mm²

The key drawn to scale.

---

## 5. Use of three-dimensional bars for only two variables

Why is this chart in 3D?

3D is fine when needed

---

## 6. Lettering too small and font difficult to read

Here the font size on the legend and key is about 1mm. (coin for scale)

All the problems are trivial to fix

---

## 10. Key outside the graph

Here the problem is not that the key is in text format (although it does not help). The problem is the distance between the key and the data.

Data

Key

---

## 11. Unnecessary numbers in the axis

Do we really need every integer from zero to 25 in this chart? (if "yes", then make a table, not a figure)

In this version, I can still find, say "23", by locating 20 and counting three check marks.

This problem is more common in the X-axis

---

## 12. Multiple colors map to the same shade of gray

This image works fine in color…

In B/W however, multiples colors map to the same shades of gray.

Note that we can easily represent upto 5 things with shades of gray. We can also directly label bars.

---

## 13. Unnecessary shading in background

All the other problems (Multiple colors map to the same shade of gray, etc) are compounded by having a shaded background.

---

## 14 Using bitmap graphics

Below is a particularly bad example, compounded by a tiny font size, however even the best bitmaps look amateurish and can hard to read.

Use vector graphics.

Bitmap graphics often have compression artifacts, resulting in noise around sharp lines.

---

## 15 General Carelessness

Why did the authors of this graphic not spend the 30 seconds it took to fix this problem?

Such careless figures are an insult to reviewers.

---

## Top Ten Avoidable Reasons Papers get Rejected, with Solutions

---

## To catch a thief, you must think like a thief

— Old French Proverb

To convince a reviewer, you must think like a reviewer

Always write your paper imagining the most cynical reviewer looking over your shoulder. This reviewer does not particularly like you, does not have a lot of time to spend on your paper, and does not think you are working in an interesting area. But he will listen to reason.

---

## 1. This paper is out of scope for SIGKDD

- In some cases, your paper may really be irretrievably out of scope, so send it elsewhere.
- Solution
  - Did you read and reference SIGKDD papers?
  - Did you frame the problem as a KDD problem?
  - Did you test on well known SIGKDD datasets?
  - Did you use the common SIGKDD evaluation metrics?
  - Did you use SIGKDD formatting? ("look and feel")
  - Can you write an explicit section that says: At first blush this problem might seem like a signal processing problem, but note that..

---

## 2. The experiments are not reproducible

- This is becoming more and more common as a reason for rejection and some conferences now have official standards for reproducibility
- Solution
  - Create a webpage with all the data and the paper itself.
  - Do the following sanity check. Assume you lose all files. Using just the webpage, can you recreate all the experiments in your paper? (it is easy to fool yourself here, really really think about this, or have a grad student actually attempt it).
  - Forcing yourself to do this will eliminate 99% of the problems

---

## 3. this is too similar to your last paper

- If you really are trying to "double-dip" then this is a justifiable reject.
- Solution
  - Did you reference your previous work?
  - Did you explicitly spend at least a paragraph explaining how you are extending that work (or, are different to that work).
  - Are you reusing all your introduction text and figures etc. It might be worth the effort to redo them.
  - If your last paper measured, say, accuracy on dataset X, and this paper is also about improving accuracy, did you compare to your last work on X? (note that this does not exclude you from additional datasets/rival methods, but if you don't compare to your previous work, you look like you are hiding something)

---

## 4. You did not acknowledge this weakness

- This looks like you either don't know it is a weakness (you are an idiot) or you are pretending it is not a weakness (you are a liar).
- Solution
  - Explicitly acknowledge the weaknesses, and explain why the work is still useful (and, if possible, how it might be fixed)
  - "While our algorithm only works for discrete data, as we noted in section 4, there are commercially important problems in the discrete domain. We further believe that we may be able to mitigate this weakness by considering…"

---

## 5. You unfairly diminish others work

- Compare:
  - "In her inspiring paper Smith shows.... We extend her foundation by mitigating the need for..."
  - "Smith's idea is slow and clumsy.... we fixed it."
- Some reviewers noted that they would not explicitly tell the authors that they felt their papers was unfairly critical/dismissive (such subjective feedback takes time to write), but it would temper how they felt about the paper.
- Solution
  - Send a preview to the rival authors: "Dear Sue, we are trying to extend your idea and we wanted to make sure that we represented your work correctly and fairly, would you mind taking a look at this preview…"

---

## 6. there is a easier way to solve this problem. you did not compare to the X algorithm

- Solution
  - Include simple strawmen ("while we do not expect the hamming distance to work well for the reasons we discussed, we include it for completeness")
  - Write an explicit explanation as to why other methods won't work (see below). But don't just say "Smith says the hamming distance is not good, so we didn't try it"

---

## 7. you do not reference this related work. this idea is already known, see Lee 1978

- Solution
  - Do a detailed literature search.
  - If the related literature is huge, write a longer tech report and say in your paper "The related work in this area is vast, we refer the interested reader to our tech-report for a more detailed survey"
  - Give a draft of your paper to mock-reviewers ahead of time.
  - Even if you have accidentally rediscovered a known result, you might be able to fix this if you know ahead of time. For example "In our paper we reintroduced an obscure result from cartography to data mining and show…"
  - (In ten years I have rejected 4 papers that rediscovered the Douglas-Peuker algorithm.)

---

## 8. you have too many parameters/magic numbers/arbitrary choices

- Solution
  - For every parameter, either:
    - Show how you can set the value (by theory or experiment)
    - Show your idea is not sensitive to the exact values
  - Explain every choice.
    - If your choice was arbitrary, state that explicitly. We used single linkage in all our experiments, we also tried average, group and Wards linkage, but found it made almost no difference, so we omitted those results for brevity.
    - If your choice was not arbitrary, justify it. We chose DCT instead of the more traditional DFT for three reasons, which are…

---

## 9. Not an interesting or important problem. Why do we care?

- Solution
  - Did you test on real data?
  - Did you have a domain expert collaborator help with motivation?
  - Did you explicitly state why this is an important problem?
  - Can you estimate value? "In this case switching from motif 8 to motif 5 gives us a nearly $40,000 in annual savings! Patnaiky et al. SIGKDD 2009"
  - Note that estimated value does not have to be in dollars, it could be in crimes solved, lives saved etc

---

## 10. The writing is generally careless. There are many typos, unclear figures

This may seem unfair if your paper has a good idea, but reviewing carelessly written papers is frustrating. Many reviewers will assume that you put as much care into the experiments as you did with the presentation.

- Solution
  - Finish writing well ahead of time, pay someone to check the writing.
  - Use mock reviewers.
  - Take pride in your work!

---

## Tutorial Summary

- Publishing in top tier venues such as SIGKDD can seem daunting, and can be frustrating…
- But you can do it!

- Taking a systematic approach, and being self-critical at every stage will help you chances greatly.
- Having an external critical eye (mock-reviewers) will also help you chances greatly.

---

## The End

---

## Appendix A:

Why mock reviewers can help

A mock reviewer might have spotted that "upward shift" was misspelled, or that "Negro" is not a good choice of words, or…

---

## Appendix B: Be concrete

SAX is a kind of statistical algorithm…
No, SAX is a data representation

Finally, Dynamic Time Warping metric was…
The same dynamic time warping metric was used to compare clusters…
… or dynamic time warping metric and to retrieve the last sensor data…
No, Dynamic Time Warping is a measure, not a metric

---

## Appendix C:

The owner of a small company needed to get rid of an old boiler that his company had replaced with a shiny new one. Not wanting to pay disposal fees, and thinking that someone else could use it, he dragged it out onto the street and put a "Free" sign on it. To his dismay, a week later it was still there. He was about to call a disposal company when his foreman said "I can get rid of it in one day".

The foreman replaced the "Free" sign with one that said "For Sale, $1,500". That night, the boiler was stolen.

The moral? Imply value for your paper.
