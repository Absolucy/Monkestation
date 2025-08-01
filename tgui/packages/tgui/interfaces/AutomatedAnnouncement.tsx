import { BooleanLike } from 'common/react';
import { multiline } from 'common/string';
import { useBackend } from '../backend';
import { Button, Input, LabeledList, Section } from '../components';
import { Window } from '../layouts';

const TOOLTIP_TEXT = multiline`
  %PERSON will be replaced with their name.
  %RANK with their job.
`;

const TOOLTIP_NODE = `
  %NODE will be replaced with the researched node.
`;

type Data = {
  arrivalToggle: BooleanLike;
  arrival: string;
  newheadToggle: BooleanLike;
  newhead: string;
  node_toggle: BooleanLike;
  node_message: string;
};

export const AutomatedAnnouncement = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    arrivalToggle,
    arrival,
    newheadToggle,
    newhead,
    node_toggle,
    node_message,
  } = data;
  return (
    <Window title="Automated Announcement System" width={500} height={225}>
      <Window.Content>
        <Section
          title="Arrival Announcement"
          buttons={
            <Button
              icon={arrivalToggle ? 'power-off' : 'times'}
              selected={arrivalToggle}
              content={arrivalToggle ? 'On' : 'Off'}
              onClick={() => act('ArrivalToggle')}
            />
          }
        >
          <LabeledList>
            <LabeledList.Item
              label="Message"
              buttons={
                <Button
                  icon="info"
                  tooltip={TOOLTIP_TEXT}
                  tooltipPosition="left"
                />
              }
            >
              <Input
                fluid
                value={arrival}
                onChange={(e, value) =>
                  act('ArrivalText', {
                    newText: value,
                  })
                }
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title="Departmental Head Announcement"
          buttons={
            <Button
              icon={newheadToggle ? 'power-off' : 'times'}
              selected={newheadToggle}
              content={newheadToggle ? 'On' : 'Off'}
              onClick={() => act('NewheadToggle')}
            />
          }
        >
          <LabeledList>
            <LabeledList.Item
              label="Message"
              buttons={
                <Button
                  icon="info"
                  tooltip={TOOLTIP_TEXT}
                  tooltipPosition="left"
                />
              }
            >
              <Input
                fluid
                value={newhead}
                onChange={(e, value) =>
                  act('NewheadText', {
                    newText: value,
                  })
                }
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title="Research Node Announcement"
          buttons={
            <Button
              icon={node_toggle ? 'power-off' : 'times'}
              selected={node_toggle}
              content={node_toggle ? 'On' : 'Off'}
              onClick={() => act('node_toggle')}
            />
          }
        >
          <LabeledList>
            <LabeledList.Item
              label="Message"
              buttons={
                <Button
                  icon="info"
                  tooltip={TOOLTIP_NODE}
                  tooltipPosition="left"
                />
              }
            >
              <Input
                fluid
                value={node_message}
                onChange={(e, value) =>
                  act('node_message', {
                    newText: value,
                  })
                }
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
