import { pickWeighted } from './random';

describe('pickWeighted', () => {
  const originalRandom = Math.random;

  afterEach(() => {
    jest.spyOn(Math, 'random').mockRestore();
  });

  afterAll(() => {
    Math.random = originalRandom;
  });

  it('excludes zero and negative weights from the draw', () => {
    jest.spyOn(Math, 'random').mockReturnValue(0);

    expect(
      pickWeighted([
        { id: 'off', weight: 0 },
        { id: 'negative', weight: -10 },
        { id: 'on', weight: 0.5 },
      ]),
    ).toEqual({ id: 'on', weight: 0.5 });
  });

  it('returns null when every item is weighted off', () => {
    expect(
      pickWeighted([
        { id: 'off', weight: 0 },
        { id: 'also-off', weight: -1 },
      ]),
    ).toBeNull();
  });
});
