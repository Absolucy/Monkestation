import { map, sortBy } from 'common/collections';
import { useBackend, useLocalState } from '../backend';
import {
  Button,
  Section,
  Modal,
  Tabs,
  Box,
  Input,
  LabeledList,
  Flex,
  ProgressBar,
  Collapsible,
  Icon,
  Divider,
} from '../components';
import { Window, NtosWindow } from '../layouts';
import { Experiment } from './ExperimentConfigure';

// Data reshaping / ingestion (thanks stylemistake for the help, very cool!)
// This is primarily necessary due to measures that are taken to reduce the size
// of the sent static JSON payload to as minimal of a size as possible
// as larger sizes cause a delay for the user when opening the UI.

const remappingIdCache = {};
const remapId = (id) => remappingIdCache[id];

const selectRemappedStaticData = (data) => {
  // Handle reshaping of node cache to fill in unsent fields, and
  // decompress the node IDs
  const node_cache = {};
  for (let id of Object.keys(data.static_data.node_cache)) {
    const node = data.static_data.node_cache[id];
    const costs = Object.keys(node.costs || {}).map((x) => ({
      type: remapId(x),
      value: node.costs[x],
    }));
    node_cache[remapId(id)] = {
      ...node,
      id: remapId(id),
      costs,
      prereq_ids: map(remapId)(node.prereq_ids || []),
      design_ids: map(remapId)(node.design_ids || []),
      unlock_ids: map(remapId)(node.unlock_ids || []),
      required_experiments: node.required_experiments || [],
      discount_experiments: node.discount_experiments || [],
    };
  }

  // Do the same as the above for the design cache
  const design_cache = {};
  for (let id of Object.keys(data.static_data.design_cache)) {
    const [name, classes] = data.static_data.design_cache[id];
    design_cache[remapId(id)] = {
      name: name,
      class: classes.startsWith('design') ? classes : `design32x32 ${classes}`,
    };
  }

  return {
    node_cache,
    design_cache,
  };
};

let remappedStaticData;

const useRemappedBackend = () => {
  const { data, ...rest } = useBackend();
  // Only remap the static data once, cache for future use
  if (!remappedStaticData) {
    const id_cache = data.static_data.id_cache;
    for (let i = 0; i < id_cache.length; i++) {
      remappingIdCache[i + 1] = id_cache[i];
    }
    remappedStaticData = selectRemappedStaticData(data);
  }
  return {
    data: {
      ...data,
      ...remappedStaticData,
    },
    ...rest,
  };
};

// Actual Components

export const Techweb = (props) => {
  return (
    <Window width={640} height={735}>
      <Window.Content scrollable>
        <TechwebStart />
      </Window.Content>
    </Window>
  );
};

const TechwebStart = (props) => {
  const { act, data } = useBackend();
  const { locked, stored_research } = data;
  if (locked) {
    return (
      <Modal width="15em" align="center" className="Techweb__LockedModal">
        <div>
          <b>Console Locked</b>
        </div>
        <Button icon="unlock" onClick={() => act('toggleLock')}>
          Unlock
        </Button>
      </Modal>
    );
  }
  if (!stored_research) {
    return (
      <Modal width="25em" align="center" className="Techweb__LockedModal">
        <div>
          <b>No research techweb found, please synchronize the console.</b>
        </div>
      </Modal>
    );
  }
  return <TechwebContent />;
};

export const AppTechweb = (props) => {
  const { act, data } = useRemappedBackend();
  const { locked } = data;
  return (
    <NtosWindow width={640} height={735}>
      <NtosWindow.Content scrollable>
        <TechwebStart />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

export const TechwebContent = (props) => {
  const { act, data } = useRemappedBackend();
  const {
    points,
    points_last_tick,
    web_org,
    sec_protocols,
    t_disk,
    d_disk,
    locked,
    queue_nodes = [],
    node_cache,
  } = data;
  const [techwebRoute, setTechwebRoute] = useLocalState('techwebRoute', null);
  const [lastPoints, setLastPoints] = useLocalState('lastPoints', {});

  return (
    <Flex direction="column" className="Techweb__Viewport" height="100%">
      <Flex.Item className="Techweb__HeaderSection">
        <Flex className="Techweb__HeaderContent">
          <Flex.Item>
            <LabeledList>
              <LabeledList.Item label="Security">
                <span
                  className={`Techweb__SecProtocol ${
                    !!sec_protocols && 'engaged'
                  }`}
                >
                  {sec_protocols ? 'Engaged' : 'Disengaged'}
                </span>
              </LabeledList.Item>
              {Object.keys(points).map((k) => (
                <LabeledList.Item key={k}>
                  <b>{k}</b>: {points[k]}
                  {!!points_last_tick[k] && ` (+${points_last_tick[k]}/sec)`}
                </LabeledList.Item>
              ))}
              <LabeledList.Item label="Queue">
                {queue_nodes.length !== 0
                  ? Object.keys(queue_nodes).map((node_id) => (
                      <Button
                        key={node_id}
                        tooltip={`Added by: ${queue_nodes[node_id]}`}
                      >
                        {node_cache[node_id].name}
                      </Button>
                    ))
                  : 'Empty'}
              </LabeledList.Item>
            </LabeledList>
          </Flex.Item>
          <Flex.Item grow={1} />
          <Flex.Item>
            <Button fluid onClick={() => act('toggleLock')} icon="lock">
              Lock Console
            </Button>
            {d_disk && (
              <Flex.Item>
                <Button
                  fluid
                  onClick={() =>
                    setTechwebRoute({ route: 'disk', diskType: 'design' })
                  }
                >
                  Design Disk Inserted
                </Button>
              </Flex.Item>
            )}
            {t_disk && (
              <Flex.Item>
                <Button
                  fluid
                  onClick={() =>
                    setTechwebRoute({ route: 'disk', diskType: 'tech' })
                  }
                >
                  Tech Disk Inserted
                </Button>
              </Flex.Item>
            )}
          </Flex.Item>
        </Flex>
      </Flex.Item>
      <Flex.Item className="Techweb__RouterContent" height="100%">
        <TechwebRouter />
      </Flex.Item>
    </Flex>
  );
};

const TechwebRouter = (props) => {
  const [techwebRoute] = useLocalState('techwebRoute', null);

  const route = techwebRoute?.route;
  const RoutedComponent =
    (route === 'details' && TechwebNodeDetail) ||
    (route === 'disk' && TechwebDiskMenu) ||
    TechwebOverview;

  return <RoutedComponent {...techwebRoute} />;
};

const TechwebOverview = (props) => {
  const { act, data } = useRemappedBackend();
  const { nodes, node_cache, design_cache } = data;
  const [tabIndex, setTabIndex] = useLocalState('overviewTabIndex', 1);
  const [searchText, setSearchText] = useLocalState('searchText');

  // Only search when 3 or more characters have been input
  const searching = searchText && searchText.trim().length > 1;

  let displayedNodes = nodes;
  if (searching) {
    displayedNodes = displayedNodes.filter((x) => {
      const n = node_cache[x.id];
      return (
        n.name.toLowerCase().includes(searchText) ||
        n.description.toLowerCase().includes(searchText) ||
        n.design_ids.some((e) =>
          design_cache[e].name.toLowerCase().includes(searchText),
        )
      );
    });
  } else {
    displayedNodes = sortBy((x) => node_cache[x.id].name)(
      tabIndex < 2
        ? nodes.filter((x) => x.tier === tabIndex)
        : nodes.filter((x) => x.tier >= tabIndex),
    );
  }

  const switchTab = (tab) => {
    setTabIndex(tab);
    setSearchText(null);
  };

  return (
    <Flex direction="column" height="100%">
      <Flex.Item>
        <Flex justify="space-between" className="Techweb__HeaderSectionTabs">
          <Flex.Item align="center" className="Techweb__HeaderTabTitle">
            Web View
          </Flex.Item>
          <Flex.Item grow={1}>
            <Tabs>
              <Tabs.Tab
                selected={!searching && tabIndex === 0}
                onClick={() => switchTab(0)}
              >
                Researched
              </Tabs.Tab>
              <Tabs.Tab
                selected={!searching && tabIndex === 1}
                onClick={() => switchTab(1)}
              >
                Available
              </Tabs.Tab>
              <Tabs.Tab
                selected={!searching && tabIndex === 2}
                onClick={() => switchTab(2)}
              >
                Future
              </Tabs.Tab>
              {!!searching && <Tabs.Tab selected>Search Results</Tabs.Tab>}
            </Tabs>
          </Flex.Item>
          <Flex.Item align={'center'}>
            <Input
              value={searchText}
              onInput={(e, value) => setSearchText(value)}
              placeholder={'Search...'}
            />
          </Flex.Item>
        </Flex>
      </Flex.Item>
      <Flex.Item className={'Techweb__OverviewNodes'} height="100%">
        {displayedNodes.map((n) => {
          return <TechNode node={n} key={n.id} />;
        })}
      </Flex.Item>
    </Flex>
  );
};

const TechwebNodeDetail = (props) => {
  const { act, data } = useRemappedBackend();
  const { nodes } = data;
  const { selectedNode } = props;

  const selectedNodeData =
    selectedNode && nodes.find((x) => x.id === selectedNode);
  return <TechNodeDetail node={selectedNodeData} />;
};

const TechwebDiskMenu = (props) => {
  const { act, data } = useRemappedBackend();
  const { diskType } = props;
  const { t_disk, d_disk } = data;
  const [techwebRoute, setTechwebRoute] = useLocalState('techwebRoute', null);

  // Check for the disk actually being inserted
  if ((diskType === 'design' && !d_disk) || (diskType === 'tech' && !t_disk)) {
    return null;
  }

  const DiskContent =
    (diskType === 'design' && TechwebDesignDisk) || TechwebTechDisk;
  return (
    <Flex direction="column" height="100%">
      <Flex.Item>
        <Flex justify="space-between" className="Techweb__HeaderSectionTabs">
          <Flex.Item align="center" className="Techweb__HeaderTabTitle">
            {diskType.charAt(0).toUpperCase() + diskType.slice(1)} Disk
          </Flex.Item>
          <Flex.Item grow={1}>
            <Tabs>
              <Tabs.Tab selected>Stored Data</Tabs.Tab>
            </Tabs>
          </Flex.Item>
          <Flex.Item align="center">
            {diskType === 'tech' && (
              <Button icon="save" onClick={() => act('loadTech')}>
                Web &rarr; Disk
              </Button>
            )}
            <Button
              icon="upload"
              onClick={() => act('uploadDisk', { type: diskType })}
            >
              Disk &rarr; Web
            </Button>
            <Button
              icon="eject"
              onClick={() => {
                act('ejectDisk', { type: diskType });
                setTechwebRoute(null);
              }}
            >
              Eject
            </Button>
            <Button icon="home" onClick={() => setTechwebRoute(null)}>
              Home
            </Button>
          </Flex.Item>
        </Flex>
      </Flex.Item>
      <Flex.Item grow={1} className="Techweb__OverviewNodes">
        <DiskContent />
      </Flex.Item>
    </Flex>
  );
};

const TechwebDesignDisk = (props) => {
  const { act, data } = useRemappedBackend();
  const { design_cache, d_disk } = data;
  const { blueprints } = d_disk;

  return (
    <>
      {blueprints.map((x, i) => (
        <Section key={i} title={`Slot ${i + 1}`}>
          {(x === null && 'Empty') || (
            <>
              Contains the design for <b>{design_cache[x].name}</b>:<br />
              <span
                className={`${design_cache[x].class} Techweb__DesignIcon`}
              />
            </>
          )}
        </Section>
      ))}
    </>
  );
};

const TechwebTechDisk = (props) => {
  const { act, data } = useRemappedBackend();
  const { t_disk } = data;
  const { stored_research } = t_disk;

  return Object.keys(stored_research)
    .map((x) => ({ id: x }))
    .map((n) => <TechNode key={n.id} nocontrols node={n} />);
};

const TechNodeDetail = (props) => {
  const { act, data } = useRemappedBackend();
  const { nodes, node_cache } = data;
  const { node } = props;
  const { id } = node;
  const { prereq_ids, unlock_ids } = node_cache[id];
  const [tabIndex, setTabIndex] = useLocalState('nodeDetailTabIndex', 0);
  const [techwebRoute, setTechwebRoute] = useLocalState('techwebRoute', null);

  const prereqNodes = nodes.filter((x) => prereq_ids.includes(x.id));
  const complPrereq = prereq_ids.filter(
    (x) => nodes.find((y) => y.id === x)?.tier === 0,
  ).length;
  const unlockedNodes = nodes.filter((x) => unlock_ids.includes(x.id));

  return (
    <Flex direction="column" height="100%">
      <Flex.Item shrink={1}>
        <Flex justify="space-between" className="Techweb__HeaderSectionTabs">
          <Flex.Item align="center" className="Techweb__HeaderTabTitle">
            Node
          </Flex.Item>
          <Flex.Item grow={1}>
            <Tabs>
              <Tabs.Tab
                selected={tabIndex === 0}
                onClick={() => setTabIndex(0)}
              >
                Required ({complPrereq}/{prereqNodes.length})
              </Tabs.Tab>
              <Tabs.Tab
                selected={tabIndex === 1}
                disabled={unlockedNodes.length === 0}
                onClick={() => setTabIndex(1)}
              >
                Unlocks ({unlockedNodes.length})
              </Tabs.Tab>
            </Tabs>
          </Flex.Item>
          <Flex.Item align="center">
            <Button icon="home" onClick={() => setTechwebRoute(null)}>
              Home
            </Button>
          </Flex.Item>
        </Flex>
      </Flex.Item>
      <Flex.Item className="Techweb__OverviewNodes" shrink={0}>
        <TechNode node={node} nodetails />
        <Divider />
      </Flex.Item>
      {tabIndex === 0 && (
        <Flex.Item className="Techweb__OverviewNodes" grow={1}>
          {prereqNodes.map((n) => (
            <TechNode key={n.id} node={n} />
          ))}
        </Flex.Item>
      )}
      {tabIndex === 1 && (
        <Flex.Item className="Techweb__OverviewNodes" grow={1}>
          {unlockedNodes.map((n) => (
            <TechNode key={n.id} node={n} />
          ))}
        </Flex.Item>
      )}
    </Flex>
  );
};

const TechNode = (props) => {
  const { act, data } = useRemappedBackend();
  const {
    node_cache,
    design_cache,
    experiments,
    points,
    nodes,
    queue_nodes = [],
    point_types_abbreviations = [],
  } = data;
  const { node, nodetails, nocontrols } = props;
  const {
    id,
    can_unlock,
    have_experiments_done,
    tier,
    enqueued_by_user,
    is_free,
  } = node;
  const {
    name,
    description,
    costs,
    design_ids,
    prereq_ids,
    required_experiments,
    discount_experiments,
  } = node_cache[id];
  const [techwebRoute, setTechwebRoute] = useLocalState('techwebRoute', null);
  const [tabIndex, setTabIndex] = useLocalState('nodeDetailTabIndex', 0);

  const expcompl = required_experiments.filter(
    (x) => experiments[x]?.completed,
  ).length;
  const experimentProgress = (
    <ProgressBar
      ranges={{
        good: [0.5, Infinity],
        average: [0.25, 0.5],
        bad: [-Infinity, 0.25],
      }}
      value={expcompl / required_experiments.length}
    >
      Experiments ({expcompl}/{required_experiments.length})
    </ProgressBar>
  );

  const techcompl = prereq_ids.filter(
    (x) => nodes.find((y) => y.id === x)?.tier === 0,
  ).length;
  const techProgress = (
    <ProgressBar
      ranges={{
        good: [0.5, Infinity],
        average: [0.25, 0.5],
        bad: [-Infinity, 0.25],
      }}
      value={techcompl / prereq_ids.length}
    >
      Tech ({techcompl}/{prereq_ids.length})
    </ProgressBar>
  );

  // Notice that this logic will have to be changed if we make the discounts
  // pool-specific
  const nodeDiscount = Object.keys(discount_experiments)
    .filter((x) => experiments[x]?.completed)
    .reduce((tot, curr) => {
      return tot + discount_experiments[curr];
    }, 0);

  return (
    <Section
      className="Techweb__NodeContainer"
      title={name}
      buttons={
        !nocontrols && (
          <>
            {tier > 0 &&
              (!!can_unlock && (is_free || queue_nodes.length === 0) ? (
                <Button
                  icon="lightbulb"
                  disabled={!can_unlock || tier > 1 || queue_nodes.length > 0}
                  onClick={() => act('researchNode', { node_id: id })}
                >
                  Research
                </Button>
              ) : enqueued_by_user ? (
                <Button
                  icon="trash"
                  color="bad"
                  onClick={() => act('dequeueNode', { node_id: id })}
                >
                  Dequeue
                </Button>
              ) : id in queue_nodes && !enqueued_by_user ? (
                <Button icon="check" color="good">
                  Queued
                </Button>
              ) : (
                <Button
                  icon="lightbulb"
                  disabled={
                    !have_experiments_done ||
                    id in queue_nodes ||
                    techcompl < prereq_ids.length
                  }
                  onClick={() => act('enqueueNode', { node_id: id })}
                >
                  Enqueue
                </Button>
              ))}
            {!nodetails && (
              <Button
                icon="tasks"
                onClick={() => {
                  setTechwebRoute({ route: 'details', selectedNode: id });
                  setTabIndex(0);
                }}
              >
                Details
              </Button>
            )}
          </>
        )
      }
    >
      {tier !== 0 && (
        <Flex className="Techweb__NodeProgress">
          {costs.map((k) => {
            const reqPts = Math.max(0, k.value - nodeDiscount);
            const nodeProg = Math.min(reqPts, points[k.type]) || 0;
            return (
              <Flex.Item key={k.type} grow={1} basis={0}>
                <ProgressBar
                  ranges={{
                    good: [0.5, Infinity],
                    average: [0.25, 0.5],
                    bad: [-Infinity, 0.25],
                  }}
                  value={
                    reqPts === 0
                      ? 1
                      : Math.min(1, (points[k.type] || 0) / reqPts)
                  }
                >
                  {point_types_abbreviations[k.type]} ({nodeProg}/{reqPts})
                </ProgressBar>
              </Flex.Item>
            );
          })}
          {prereq_ids.length > 0 && (
            <Flex.Item grow={1} basis={0}>
              {techProgress}
            </Flex.Item>
          )}
          {required_experiments.length > 0 && (
            <Flex.Item grow={1} basis={0}>
              {experimentProgress}
            </Flex.Item>
          )}
        </Flex>
      )}
      <Box className="Techweb__NodeDescription" mb={2}>
        {description}
      </Box>
      <Box className="Techweb__NodeUnlockedDesigns" mb={2}>
        {design_ids.map((k, i) => (
          <Button
            key={id}
            className={`${design_cache[k].class} Techweb__DesignIcon`}
            tooltip={design_cache[k].name}
            tooltipPosition={i % 15 < 7 ? 'right' : 'left'}
          />
        ))}
      </Box>
      {required_experiments.length > 0 && (
        <Collapsible
          className="Techweb__NodeExperimentsRequired"
          title="Required Experiments"
        >
          {required_experiments.map((k) => {
            const thisExp = experiments[k];
            if (thisExp === null || thisExp === undefined) {
              return <LockedExperiment />;
            }
            return <Experiment key={thisExp} exp={thisExp} />;
          })}
        </Collapsible>
      )}
      {Object.keys(discount_experiments).length > 0 && (
        <Collapsible
          className="TechwebNodeExperimentsRequired"
          title="Discount-Eligible Experiments"
        >
          {Object.keys(discount_experiments).map((k) => {
            const thisExp = experiments[k];
            if (thisExp === null || thisExp === undefined) {
              return <LockedExperiment />;
            }
            return (
              <Experiment key={thisExp} exp={thisExp}>
                <Box className="Techweb__ExperimentDiscount">
                  Provides a discount of {discount_experiments[k]} points to all
                  required point pools.
                </Box>
              </Experiment>
            );
          })}
        </Collapsible>
      )}
    </Section>
  );
};

const LockedExperiment = (props) => {
  return (
    <Box m={1} className="ExperimentConfigure__ExperimentPanel">
      <Button
        fluid
        backgroundColor="#40628a"
        className="ExperimentConfigure__ExperimentName"
        disabled
      >
        <Flex align="center" justify="space-between">
          <Flex.Item color="rgba(0, 0, 0, 0.6)">
            <Icon name="lock" />
            Undiscovered Experiment
          </Flex.Item>
          <Flex.Item color="rgba(0, 0, 0, 0.5)">???</Flex.Item>
        </Flex>
      </Button>
      <Box className={'ExperimentConfigure__ExperimentContent'}>
        This experiment has not been discovered yet, continue researching nodes
        in the tree to discover the contents of this experiment.
      </Box>
    </Box>
  );
};
