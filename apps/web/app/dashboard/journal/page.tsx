'use client';

import { useMemo, useState } from 'react';
import {
  BookHeart,
  BookOpenText,
  Edit3,
  Heart,
  PenLine,
  Search,
  Star,
  Trash2,
} from 'lucide-react';
import { DashboardShell } from '@/components/layout/dashboard-shell';
import {
  MetricCard,
  ProgressList,
  SectionTitle,
} from '@/components/dashboard/dashboard-ui';
import { DashboardFilterBar, useDashboardFilters } from '@/components/dashboard/dashboard-filters';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { apiFetch } from '@/lib/api';
import { useUserDashboardData } from '@/lib/live-dashboard';
import { useDashboardStore } from '@/stores/use-dashboard-store';
import { useUiStore } from '@/stores/use-ui-store';

const moodTypeOptions = [
  'HAPPY',
  'CALM',
  'TIRED',
  'SAD',
  'ANXIOUS',
  'STRESSED',
  'EXCITED',
  'NEUTRAL',
  'LONELY',
  'GRATEFUL',
];

export default function JournalPage() {
  const journalFilters = useDashboardFilters('/journals/me', 'journal');
  const refreshNonce = useDashboardStore((state) => state.refreshNonce);
  const triggerRefresh = useDashboardStore((state) => state.triggerRefresh);
  const pushToast = useUiStore((state) => state.pushToast);
  const [query, setQuery] = useState('');
  const journals = useUserDashboardData({
    refreshKey: refreshNonce,
    journalQuery: { ...journalFilters.query, q: query.trim() || undefined },
  }).overview.journals;
  const [moodFilter, setMoodFilter] = useState('ALL');
  const [draft, setDraft] = useState('');
  const [draftTitle, setDraftTitle] = useState('');
  const [draftMood, setDraftMood] = useState('NEUTRAL');
  const [draftTags, setDraftTags] = useState('web-dashboard');
  const [editingId, setEditingId] = useState<string | null>(null);
  const [saveState, setSaveState] = useState<'idle' | 'saving' | 'saved' | 'error'>('idle');
  const filtered = useMemo(
    () =>
      journals.recent.filter((journal) => {
        const matchesQuery =
          journal.title.toLowerCase().includes(query.toLowerCase()) ||
          journal.excerpt.toLowerCase().includes(query.toLowerCase()) ||
          journal.tags.join(' ').toLowerCase().includes(query.toLowerCase());
        const matchesMood = moodFilter === 'ALL' || journal.mood === moodFilter;

        return matchesQuery && matchesMood;
      }),
    [journals.recent, moodFilter, query],
  );
  const topMood = journals.byMood[0]?.mood ?? 'Chưa rõ';
  const moodOptions = useMemo(
    () => ['ALL', ...new Set(journals.byMood.map((item) => item.mood))],
    [journals.byMood],
  );
  const tagHighlights = useMemo(() => {
    const counts = new Map<string, number>();
    for (const journal of journals.recent) {
      for (const tag of journal.tags) {
        counts.set(tag, (counts.get(tag) ?? 0) + 1);
      }
    }

    return [...counts.entries()]
      .sort((a, b) => b[1] - a[1])
      .slice(0, 4);
  }, [journals.recent]);

  return (
    <DashboardShell eyebrow="Reflection" title="Journal space">
      <DashboardFilterBar {...journalFilters} title="Bộ lọc journal" />

      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <MetricCard icon={BookOpenText} label="Tổng nhật ký" value={journals.total} />
        <MetricCard icon={Star} label="Favorites" tone="sun" value={journals.favorites} />
        <MetricCard
          icon={Heart}
          label="Mood nổi bật"
          note="xuất hiện nhiều nhất"
          tone="coral"
          value={topMood}
        />
        <MetricCard
          icon={BookHeart}
          label="Recent entries"
          note="bản ghi gần đây"
          tone="mint"
          value={journals.recent.length}
        />
      </div>

      <div className="grid gap-4 xl:grid-cols-[minmax(0,1fr)_360px]">
        <Card>
          <SectionTitle
            title="Danh sách nhật ký"
            copy="Tìm lại những entry gần đây theo cảm xúc, từ khóa và nhịp ghi chép của anh."
            action={
              <div className="flex flex-wrap gap-2">
                <div className="flex h-10 items-center gap-2 rounded-lg border border-lilac bg-white px-3 text-sm">
                  <Search className="h-4 w-4 text-violet" />
                  <input
                    className="w-40 bg-transparent outline-none"
                    onChange={(event) => setQuery(event.target.value)}
                    placeholder="Tìm nhật ký"
                    value={query}
                  />
                </div>
                <select
                  className="h-10 rounded-lg border border-lilac bg-white px-3 text-sm font-semibold text-ink"
                  onChange={(event) => setMoodFilter(event.target.value)}
                  value={moodFilter}
                >
                  {moodOptions.map((option) => (
                    <option key={option} value={option}>
                      {option === 'ALL' ? 'All mood' : option}
                    </option>
                  ))}
                </select>
              </div>
            }
          />
          <div className="mt-5 space-y-3">
            {filtered.length > 0 ? filtered.map((journal) => (
              <article
                className="rounded-lg border border-lilac/70 bg-white/75 p-4"
                key={journal.id}
              >
                <div className="flex flex-wrap items-center justify-between gap-3">
                  <div>
                    <h3 className="text-lg font-extrabold text-ink">{journal.title}</h3>
                    <p className="mt-1 text-xs font-semibold text-slate">{journal.createdAt}</p>
                  </div>
                  <span className="rounded-md bg-lilac/50 px-2 py-1 text-xs font-bold text-plum">
                    {journal.mood}
                  </span>
                </div>
                <p className="mt-3 text-sm leading-6 text-slate">{journal.excerpt}</p>
                <div className="mt-4 flex flex-wrap gap-2">
                  {journal.tags.map((tag) => (
                    <span className="rounded-md bg-cloud px-2 py-1 text-xs font-bold text-ink" key={tag}>
                      #{tag}
                    </span>
                  ))}
                </div>
                <div className="mt-4 flex flex-wrap gap-2">
                  <Button
                    className="h-8 px-3 text-xs"
                    onClick={() => {
                      setEditingId(journal.id);
                      setDraftTitle(journal.title);
                      setDraft(journal.content || journal.excerpt);
                      setDraftMood(journal.moodType || 'NEUTRAL');
                      setDraftTags(journal.tags.join(', '));
                    }}
                    variant="secondary"
                  >
                    <Edit3 className="h-3.5 w-3.5" />
                    Sửa
                  </Button>
                  <Button
                    className="h-8 px-3 text-xs"
                    onClick={async () => {
                      try {
                        await apiFetch(`/journals/${journal.id}`, {
                          method: 'PATCH',
                          body: JSON.stringify({ isFavorite: !journal.favorite }),
                        });
                        triggerRefresh();
                        pushToast({
                          tone: 'success',
                          title: journal.favorite
                            ? 'Đã bỏ yêu thích'
                            : 'Đã đánh dấu yêu thích',
                        });
                      } catch {
                        pushToast({ tone: 'error', title: 'Không đổi được favorite' });
                      }
                    }}
                    variant="secondary"
                  >
                    <Heart className="h-3.5 w-3.5" />
                    {journal.favorite ? 'Bỏ favorite' : 'Favorite'}
                  </Button>
                  <Button
                    className="h-8 px-3 text-xs"
                    onClick={async () => {
                      try {
                        await apiFetch(`/journals/${journal.id}`, { method: 'DELETE' });
                        triggerRefresh();
                        pushToast({
                          tone: 'success',
                          title: 'Đã xoá nhật ký',
                          message: journal.title,
                        });
                      } catch {
                        pushToast({ tone: 'error', title: 'Không xoá được nhật ký' });
                      }
                    }}
                  >
                    <Trash2 className="h-3.5 w-3.5" />
                    Xoá
                  </Button>
                </div>
              </article>
            )) : (
              <div className="rounded-lg border border-dashed border-lilac bg-white/70 p-6 text-sm font-medium text-slate">
                Chưa có entry nào khớp bộ lọc hiện tại. Thử bỏ bớt từ khóa hoặc đổi mood xem sao.
              </div>
            )}
          </div>
        </Card>

        <Card>
          <SectionTitle
            title={editingId ? 'Chỉnh sửa nhật ký' : 'Viết nhanh'}
            copy="Tạo mới, sửa nội dung, đổi mood/tag hoặc đánh dấu yêu thích đều ghi trực tiếp vào backend."
            action={<PenLine className="h-5 w-5 text-violet" />}
          />
          <input
            className="mt-5 h-11 w-full rounded-lg border border-lilac bg-white/85 px-3 text-sm font-semibold text-ink outline-none focus:border-violet"
            onChange={(event) => setDraftTitle(event.target.value)}
            placeholder="Tiêu đề nhật ký"
            value={draftTitle}
          />
          <div className="mt-3 grid gap-3 sm:grid-cols-2">
            <select
              className="h-11 rounded-lg border border-lilac bg-white/85 px-3 text-sm font-semibold text-ink outline-none focus:border-violet"
              onChange={(event) => setDraftMood(event.target.value)}
              value={draftMood}
            >
              {moodTypeOptions.map((option) => (
                <option key={option} value={option}>
                  {option}
                </option>
              ))}
            </select>
            <input
              className="h-11 rounded-lg border border-lilac bg-white/85 px-3 text-sm font-semibold text-ink outline-none focus:border-violet"
              onChange={(event) => setDraftTags(event.target.value)}
              placeholder="tag1, tag2"
              value={draftTags}
            />
          </div>
          <textarea
            className="mt-3 min-h-[220px] w-full rounded-lg border border-lilac bg-white/85 p-3 text-sm outline-none focus:border-violet"
            onChange={(event) => setDraft(event.target.value)}
            placeholder="Hôm nay điều gì làm anh nhẹ hơn?"
            value={draft}
          />
          <div className="mt-4 flex items-center justify-between gap-3">
            <p className="text-sm font-semibold text-slate">{draft.length}/600</p>
            <Button
              disabled={saveState === 'saving' || draft.trim().length === 0}
              onClick={async () => {
                setSaveState('saving');
                try {
                  const payload = {
                    title:
                      draftTitle.trim() ||
                      draft.trim().slice(0, 60) ||
                      'Quick reflection',
                    content: draft,
                    mood: draftMood,
                    tags: draftTags
                      .split(',')
                      .map((tag) => tag.trim().replace(/^#/, ''))
                      .filter(Boolean)
                      .slice(0, 10),
                  };

                  if (editingId) {
                    await apiFetch(`/journals/${editingId}`, {
                      method: 'PATCH',
                      body: JSON.stringify(payload),
                    });
                  } else {
                    await apiFetch('/journals/me', {
                      method: 'POST',
                      body: JSON.stringify({
                        ...payload,
                        isPrivate: true,
                      }),
                    });
                  }
                  setSaveState('saved');
                  setEditingId(null);
                  setDraftTitle('');
                  setDraft('');
                  setDraftMood('NEUTRAL');
                  setDraftTags('web-dashboard');
                  triggerRefresh();
                  pushToast({
                    tone: 'success',
                    title: editingId ? 'Đã cập nhật nhật ký' : 'Đã lưu nhật ký',
                    message: 'Danh sách recent entries đang được làm mới.',
                  });
                } catch {
                  setSaveState('error');
                  pushToast({
                    tone: 'error',
                    title: 'Không lưu được nhật ký',
                  });
                }
              }}
            >
              <PenLine className="h-4 w-4" />
              {saveState === 'saving' ? 'Đang lưu' : editingId ? 'Cập nhật' : 'Lưu nhật ký'}
            </Button>
          </div>
          {editingId ? (
            <Button
              className="mt-3"
              onClick={() => {
                setEditingId(null);
                setDraftTitle('');
                setDraft('');
                setDraftMood('NEUTRAL');
                setDraftTags('web-dashboard');
              }}
              variant="secondary"
            >
              Huỷ sửa
            </Button>
          ) : null}
          {saveState === 'saved' || saveState === 'error' ? (
            <p
              className={`mt-3 text-sm font-semibold ${
                saveState === 'saved' ? 'text-mint' : 'text-coral'
              }`}
            >
              {saveState === 'saved'
                ? 'Đã lưu nhật ký qua API.'
                : 'Lưu nhật ký thất bại. Không có draft giả nào được dùng thay thế.'}
            </p>
          ) : null}
          <div className="mt-6">
            <ProgressList
              items={journals.byMood.map((item) => ({
                mood: item.mood,
                percent: Math.round((item.count / journals.total) * 100),
              }))}
            />
          </div>
        </Card>
      </div>

      <div className="grid gap-4 xl:grid-cols-[minmax(0,0.9fr)_minmax(0,1.1fr)]">
        <Card>
          <SectionTitle
            title="Phân bố cảm xúc trong nhật ký"
            copy="Tỉ trọng mood trong các entry hiện có để anh nhìn ra trạng thái nào lặp lại nhiều nhất."
          />
          <div className="mt-5">
            <ProgressList
              items={journals.byMood.map((item) => ({
                mood: item.mood,
                percent:
                  journals.total > 0 ? Math.round((item.count / journals.total) * 100) : 0,
              }))}
            />
          </div>
        </Card>

        <Card>
          <SectionTitle
            title="Điểm nhấn gần đây"
            copy="Tóm tắt nhanh từ những entry mới nhất để anh biết mình đang viết về điều gì nhiều nhất."
          />
          <div className="mt-5 space-y-4">
            <InsightRow
              label="Tần suất yêu thích"
              value={`${journals.favorites}/${journals.total || 0} entry được đánh dấu`}
            />
            <InsightRow
              label="Mood dẫn đầu"
              value={`${topMood} đang xuất hiện nhiều nhất trong nhật ký`}
            />
            <InsightRow
              label="Tag nổi bật"
              value={
                tagHighlights.length > 0
                  ? tagHighlights.map(([tag, count]) => `#${tag} (${count})`).join(' • ')
                  : 'Chưa có tag nổi bật'
              }
            />
            <InsightRow
              label="Nhịp ghi gần đây"
              value={`${journals.recent.length} entry mới đang hiển thị trên màn hình`}
            />
          </div>
        </Card>
      </div>
    </DashboardShell>
  );
}

function InsightRow({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-lg border border-lilac/70 bg-white/75 p-4">
      <p className="text-xs font-semibold uppercase tracking-[0.14em] text-slate">{label}</p>
      <p className="mt-2 text-sm font-semibold text-ink">{value}</p>
    </div>
  );
}
