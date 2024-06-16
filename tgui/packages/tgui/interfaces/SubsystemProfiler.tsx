import { BooleanLike } from 'common/react';
import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';
import { Box, Button, Icon, Section, Table, Tooltip } from '../components';
import { toFixed } from 'common/math';
import { flow } from 'common/fp';
import { sortBy } from 'common/collections';

enum SubsystemState {
  /** Ain't doing shit. */
  Idle = 0,
  /** Queued to run. */
  Queued = 1,
  /** Actively running. */
  Running = 2,
  /** Paused by `MC_CHECK_TICK`. */
  Paused = 3,
  /** `fire()` slept. */
  Sleeping = 4,
  /** In the middle of pausing. */
  Pausing = 5,
}

enum SortingMode {
  Name,
  Priority,
  State,
  Focus,
  Cost,
  TickUsage,
  TickOverrun,
  Ticks,
}

type StateInfo = {
  tooltip: string;
  icon: string;
  color?: string;
};

const state_info = (state: SubsystemState): StateInfo => {
  switch (state) {
    case SubsystemState.Paused:
      return { tooltip: 'Paused', icon: 'pause-circle', color: 'danger' };
    case SubsystemState.Sleeping:
      return { tooltip: 'Sleeping', icon: 'moon', color: 'caution' };
    default:
      return { tooltip: 'Okay', icon: 'cat', color: 'label' };
  }
};

type Subsystem = {
  /**
   * The name of the subsystem.
   */
  name: string;
  /**
   * The type path of the subsystem.
   */
  path: string;
  /**
   * Time to wait (in deciseconds) between each call to fire().
   * Must be a positive integer.
   */
  wait: number;
  /**
   * Priority Weight: When mutiple subsystems need to run in the same tick,
   * higher priority subsystems will be given a higher share of the tick before
   * MC_TICK_CHECK triggers a sleep, higher priority subsystems also run before
   * lower priority subsystems.
   */
  priority: number;
  /**
   * Tracks the current execution state of the subsystem. Used to handle
   * subsystems that sleep in fire so the mc doesn't run them again while
   * they are sleeping.
   */
  state: SubsystemState;
  /**
   * If TRUE, then this subsystem will stop the world profiler after ignite()
   * returns and start it again when called.
   * Used so that you can audit a specific subsystem or group of subsystems'
   * synchronous call chain.
   */
  focused: BooleanLike;
  /**
   * Running average of the amount of milliseconds it takes the subsystem to
   * complete a run (including all resumes but not the time spent paused)
   */
  cost: number;
  /**
   * Running average of the amount of tick usage in percents of a tick it takes
   * the subsystem to complete a run.
   */
  tick_usage: number;
  /**
   * Running average of the amount of tick usage (in percents of a game tick)
   * the subsystem has spent past its allocated time without pausing.
   */
  tick_overrun: number;
  /**
   * Tracks how many fires the subsystem takes to complete a run on average.
   */
  ticks: number;
};

type SubsystemProfilerData = {
  subsystems: Subsystem[];
};

export const SubsystemEntry = (
  props: { subsystem: Subsystem },
  context: any
) => {
  const { act } = useBackend<SubsystemProfilerData>(context);
  const { name, path, focused, cost, tick_usage, tick_overrun } =
    props.subsystem;
  const state = state_info(props.subsystem.state);
  return (
    <Table.Row className="candystripe">
      <Table.Cell>{name}</Table.Cell>
      <Table.Cell textAlign="center">
        <Tooltip content={state.tooltip}>
          <Icon name={state.icon} color={state.color || 'average'} />
        </Tooltip>
      </Table.Cell>
      <Table.Cell textAlign="center">
        <Button.Checkbox
          checked={focused}
          onClick={() => act('set_focus', { subsystem: path, focus: !focused })}
          tooltip="Focus the profiler on this subsystem."
        />
      </Table.Cell>
      <Table.Cell textAlign="right">
        {toFixed(cost, 1)
          .toLocaleString()
          .padStart(5, ' ')}
        ms
      </Table.Cell>
      <Table.Cell textAlign="right">
        {toFixed(tick_usage, 1)
          .toLocaleString()
          .padStart(5, ' ')}
        %
      </Table.Cell>
      <Table.Cell textAlign="right">
        {toFixed(tick_overrun, 1)
          .toLocaleString()
          .padStart(5, ' ')}
      </Table.Cell>
    </Table.Row>
  );
};

export const SortingSelection = (_: any, context: any) => {
  const [sort, set_sort] = useLocalState<SortingMode>(
    context,
    'sort',
    SortingMode.Name
  );
  return (
    <Box mb={1}>
      <Box inline mr={2} color="label">
        Sort by:
      </Box>
      <Button.Checkbox
        checked={sort === SortingMode.Name}
        content="Name"
        onClick={() => set_sort(SortingMode.Name)}
      />
      <Button.Checkbox
        checked={sort === SortingMode.Priority}
        content="Priority"
        onClick={() => set_sort(SortingMode.Priority)}
      />
      <Button.Checkbox
        checked={sort === SortingMode.State}
        content="State"
        onClick={() => set_sort(SortingMode.State)}
      />
      <Button.Checkbox
        checked={sort === SortingMode.Focus}
        content="Focus"
        onClick={() => set_sort(SortingMode.Focus)}
      />
      <Button.Checkbox
        checked={sort === SortingMode.Cost}
        content="Cost"
        onClick={() => set_sort(SortingMode.Cost)}
      />
      <Button.Checkbox
        checked={sort === SortingMode.TickUsage}
        content="Tick Usage"
        onClick={() => set_sort(SortingMode.TickUsage)}
      />
      <Button.Checkbox
        checked={sort === SortingMode.TickOverrun}
        content="Tick Overrun"
        onClick={() => set_sort(SortingMode.TickOverrun)}
      />
      <Button.Checkbox
        checked={sort === SortingMode.Ticks}
        content="Ticks"
        onClick={() => set_sort(SortingMode.Ticks)}
      />
    </Box>
  );
};

export const SubsystemProfiler = (_: any, context: any) => {
  const { data } = useBackend<SubsystemProfilerData>(context);
  const [sort] = useLocalState<SortingMode>(context, 'sort', SortingMode.Name);
  const subsystems: Subsystem[] = flow([
    sort === SortingMode.Name && sortBy((ss: Subsystem) => ss.name),
    sort === SortingMode.Priority && sortBy((ss: Subsystem) => ss.priority),
    sort === SortingMode.State && sortBy((ss: Subsystem) => ss.state),
    sort === SortingMode.Focus && sortBy((ss: Subsystem) => ss.focused),
    sort === SortingMode.Cost && sortBy((ss: Subsystem) => ss.cost),
    sort === SortingMode.TickUsage && sortBy((ss: Subsystem) => ss.tick_usage),
    sort === SortingMode.TickOverrun &&
      sortBy((ss: Subsystem) => ss.tick_overrun),
    sort === SortingMode.Ticks && sortBy((ss: Subsystem) => ss.ticks),
  ])(data.subsystems);
  return (
    <Window width={720} height={900}>
      <Window.Content scrollable>
        <Section>
          <SortingSelection />
          <Table>
            <Table.Row header className="candystripe">
              <Table.Cell bold color="label" textAlign="center">
                Name
              </Table.Cell>
              <Table.Cell bold color="label" textAlign="center">
                State
              </Table.Cell>
              <Table.Cell bold color="label" textAlign="center">
                Profiler Focused
              </Table.Cell>
              <Table.Cell bold color="label" textAlign="center">
                Cost
              </Table.Cell>
              <Table.Cell bold color="label" textAlign="center">
                Tick Usage
              </Table.Cell>
              <Table.Cell bold color="label" textAlign="center">
                Tick Overrun
              </Table.Cell>
            </Table.Row>
            {subsystems.map((subsystem) => (
              <SubsystemEntry key={subsystem.path} subsystem={subsystem} />
            ))}
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};
