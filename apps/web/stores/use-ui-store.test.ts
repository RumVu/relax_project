import { beforeEach, describe, expect, it } from 'vitest';
import { useUiStore } from './use-ui-store';

describe('useUiStore', () => {
  beforeEach(() => {
    useUiStore.setState({ toasts: [] });
  });

  it('starts with no toasts', () => {
    expect(useUiStore.getState().toasts).toHaveLength(0);
  });

  it('pushes a toast with a generated id', () => {
    useUiStore.getState().pushToast({ title: 'Saved', tone: 'success' });
    const { toasts } = useUiStore.getState();
    expect(toasts).toHaveLength(1);
    expect(toasts[0].title).toBe('Saved');
    expect(toasts[0].tone).toBe('success');
    expect(typeof toasts[0].id).toBe('string');
    expect(toasts[0].id.length).toBeGreaterThan(0);
  });

  it('removes a toast by id', () => {
    useUiStore.getState().pushToast({ title: 'A', tone: 'info' });
    useUiStore.getState().pushToast({ title: 'B', tone: 'error' });

    const [first] = useUiStore.getState().toasts;
    useUiStore.getState().removeToast(first.id);

    const remaining = useUiStore.getState().toasts;
    expect(remaining).toHaveLength(1);
    expect(remaining[0].title).toBe('B');
  });

  it('ignores removeToast for an unknown id', () => {
    useUiStore.getState().pushToast({ title: 'A', tone: 'info' });
    useUiStore.getState().removeToast('not-a-real-id');
    expect(useUiStore.getState().toasts).toHaveLength(1);
  });
});
