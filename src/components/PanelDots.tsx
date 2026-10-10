interface PanelDotsProps {
  total: number;
  current: number;
  onChange: (index: number) => void;
}

export const PanelDots = ({ total, current, onChange }: PanelDotsProps) => {
  if (total <= 1) return null;

  return (
    <div
      role="tablist"
      aria-label="Panel Navigation"
      className="flex items-center gap-1.5 p-1 rounded-full bg-white/70 backdrop-blur-md border border-neutral-200/60 shadow-xs"
    >
      {Array.from({ length: total }).map((_, i) => {
        const isActive = i === current;
        return (
          <button
            key={i}
            type="button"
            role="tab"
            aria-selected={isActive}
            aria-label={`Go to panel ${i + 1} of ${total}`}
            onClick={() => onChange(i)}
            className={`transition-all duration-300 rounded-full cursor-pointer focus:outline-none ${
              isActive
                ? 'w-5 h-2 bg-neutral-900'
                : 'w-2 h-2 bg-neutral-300 hover:bg-neutral-500'
            }`}
          />
        );
      })}
    </div>
  );
};
