  Scenario: we have selected some checks for the hosts of a given cluster and the user triggers an execution

  what does it mean "requesting an execution for the selection"?
  could it be something like the following?

  starting the process of gathering facts form targets and evaluating expectations **for all the hosts** on a given cluster
  and recalculate the health of the single hosts and of the cluster as a whole given the checks results

  is it a usecase to start execution for the check selection of a **single host**?

  information at hand:
  - an identifier for the currently triggered execution (by the user or by time passing)
  - cluster id
  - list of the target hosts (aka agents) of the cluster
  - list of the selected checks (12ER4, FD54R, ...) - each agent has its own selection
  - provider (atm this is the cluster's provided - which is simply the discovered cluster of a host...)

  Assumptions:
  - the selected checks may vary per target agent
  - some agents might not have any selected check
  - different agents might run on different providers (? this might be skipped atm)

  Process
  - listen on incoming messages (from the server) about starting the execution for the check selection of a cluster (or of a host)
  - start an ExecutionServer process for the requested execution
  - instrument the target agents to run the facts gathering for each of its selected checks (dsl parsing, publishing messages to the agents...)
  ** About facts gathering: the DSL could be sent to the agent as part of the instrumentation request and the parsed at agent level
     or it could be interpreted in wanda and sent to the agent as a simpler structure/instructions to execute facts gathering**
  - listen on incoming messages from the agents about the gathered facts for each of its (agent's) selected checks
  - wait until all the agents have gathered all the facts for all of their selected checks
  ** errors? timeouts? retries? think! **
  - whenever all the agent have reported their gathered facts, wanda interprets the check evaluation DSLs for each of the selected checks
  - trigger checks evaluation against the correct expected value(s): provider suggestions or custom values
  - publish back to the server the status of the execution (running, completed, ...)
  - shut down the execution server

  which are the states of an execution? started, running, completed...
  when does the state transition happen? so that we can notify back the server about the progress

  should we notify back results as soon as we have them available? even if the whole execution hasn't completed yet?