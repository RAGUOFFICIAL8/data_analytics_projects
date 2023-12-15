/*CREATE TABLE deliveries(
   match_id         INTEGER  NOT NULL  
  ,inning           INTEGER  NOT NULL
  ,batting_team     VARCHAR(27) NOT NULL
  ,bowling_team     VARCHAR(27) NOT NULL
  ,over_no             INTEGER  NOT NULL
  ,ball             INTEGER  NOT NULL
  ,batsman          VARCHAR(17) NOT NULL
  ,non_striker      VARCHAR(17) NOT NULL
  ,bowler           VARCHAR(17) NOT NULL
  ,is_super_over_no    BIT  NOT NULL
  ,wide_runs        INTEGER  NOT NULL
  ,bye_runs         INTEGER  NOT NULL
  ,legbye_runs      INTEGER  NOT NULL
  ,noball_runs      INTEGER  NOT NULL
  ,penalty_runs     INTEGER  NOT NULL
  ,batsman_runs     INTEGER  NOT NULL
  ,extra_runs       INTEGER  NOT NULL
  ,total_runs       INTEGER  NOT NULL
  ,player_dismissed VARCHAR(17)
  ,dismissal_kind   VARCHAR(17)
  ,fielder          VARCHAR(20)
);*/


/*CREATE TABLE matches(
   id              INTEGER  NOT NULL PRIMARY KEY 
  ,season          INTEGER  NOT NULL
  ,city            VARCHAR(14) NOT NULL
  ,date            DATE  NOT NULL
  ,team1           VARCHAR(27) NOT NULL
  ,team2           VARCHAR(27) NOT NULL
  ,toss_winner     VARCHAR(27) NOT NULL
  ,toss_decision   VARCHAR(5) NOT NULL
  ,result          VARCHAR(6) NOT NULL
  ,dl_applied      BIT  NOT NULL
  ,winner          VARCHAR(27) NOT NULL
  ,win_by_runs     INTEGER  NOT NULL
  ,win_by_wickets  INTEGER  NOT NULL
  ,player_of_match VARCHAR(17) NOT NULL
  ,venue           VARCHAR(52) NOT NULL
  ,umpire1         VARCHAR(21)
  ,umpire2         VARCHAR(14)
  ,umpire3         VARCHAR(30)
); */

--question NO1: WHAT ARE THE TOP 5 PLAYERS WITH THE MOST PLAYER OF THE MATCH AWARDS?

select player_of_match,count(*) as awards_count
from matches group by player_of_match
order by awards_count desc 
limit 5;                                        

--"YK Pathan", "SE Marsh" ,"SR Watson" ,"NM Coulter-Nile" ,"MS Dhoni"

--Question NO 2: HOW MANY MATCHES WERE WON BY EACH TEAM IN EACH SEASON?

select season,winner as team,count(*) as matches_won
from matches group by season,winner;

--Question no : 3  WHAT IS THE AVERAGE STRIKE RATE OF BATSMEN IN THE IPL DATASET?

select avg(strike_rate) as average_strike_rate
from(
select batsman,(sum(total_runs)/count(ball))*100 as strike_rate
from deliveries group by batsman)as batsman_stats;

-- Question no 4: WHICH BATSMAN HAS THE HIGHEST STRIKE RATE (MINIMUM 200 RUNS SCORED)?

select batsman,(sum(batsman_runs)*100/count(*))
as strike_rate
from deliveries group by batsman
having sum(batsman_runs)>=200
order by strike_rate desc
limit 1;

-- Question no 5: HOW MANY TIMES HAS EACH BATSMAN BEEN DISMISSED BY THE BOWLER 'MALINGA'?

select batsman,count(*) as total_dismissals
from deliveries 
where player_dismissed is not null 
and bowler='SL Malinga'
group by batsman;

-- Question no 6: WHAT IS THE AVERAGE PERCENTAGE OF BOUNDARIES (FOURS AND SIXES COMBINED) HIT BY EACH BATSMAN?

select batsman,avg(case when batsman_runs=4 or batsman_runs=6
then 1 else 0 end)*100 as average_boundaries
from deliveries group by batsman;

--Question no 7: WHAT IS THE AVERAGE NUMBER OF BOUNDARIES HIT BY EACH TEAM IN EACH SEASON?

select season,batting_team,avg(fours+sixes) as average_boundaries
from(select season,match_id,batting_team,
sum(case when batsman_runs=4 then 1 else 0 end)as fours,
sum(case when batsman_runs=6 then 1 else 0 end) as sixes
from deliveries,matches 
where deliveries.match_id=matches.id
group by season,match_id,batting_team) as team_bounsaries
group by season,batting_team;

--Question no 8: WHAT IS THE HIGHEST PARTNERSHIP (RUNS) FOR EACH TEAM IN EACH SEASON?

select season,batting_team,max(total_runs) as highest_partnership
from(select season,batting_team,partnership,sum(total_runs) as total_runs
from(select season,match_id,batting_team,over_no,
sum(batsman_runs) as partnership,sum(batsman_runs)+sum(extra_runs) as total_runs
from deliveries,matches where deliveries.match_id=matches.id
group by season,match_id,batting_team,over_no) as team_scores
group by season,batting_team,partnership) as highest_partnership
group by season,batting_team; 


