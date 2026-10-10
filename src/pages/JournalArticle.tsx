import { useParams, Navigate } from 'react-router-dom';
import { Scene } from '../components/Scene';
import { Reader } from '../components/Reader';
import { journalArticles } from '../content/journal';

export const JournalArticle = () => {
  const { slug } = useParams<{ slug: string }>();
  const article = journalArticles.find((a) => a.slug === slug);

  if (!article) {
    return <Navigate to="/journal" replace />;
  }

  return (
    <Scene panelCount={1} currentPanel={0}>
      <Reader
        title={article.title}
        subtitle={article.subtitle}
        dateOrVersion={article.date}
        categoryOrBadge={article.category}
        backHref="/journal"
        backLabel="← All Articles"
        sources={article.sources}
      >
        <div className="space-y-4">
          {article.paragraphs.map((p, idx) => (
            <p key={idx} className="break-inside-avoid">
              {p}
            </p>
          ))}
        </div>
      </Reader>
    </Scene>
  );
};
