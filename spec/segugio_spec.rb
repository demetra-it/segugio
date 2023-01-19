# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
RSpec.describe Segugio do
  it 'has a version number' do
    expect(Segugio::VERSION).not_to be nil
  end

  describe 'an example with Post' do
    subject { Post.first }
    before { create_list(:post, 20) }

    it { should be_persisted }

    it 'should have 20 Post records' do
      expect(Post.count).to eq(20)
    end

    describe 'search by query string' do
      let(:query_str) { 'post' }
      subject { Post.search(query: query_str) }

      it 'should generate a correct SQL query' do
        Post.query_fields.each do |field|
          expect(subject.to_sql).to match(/WHERE(.*)"posts"."#{field}"::text ILIKE '%#{query_str}%'/)
        end
      end
    end

    describe 'filter by status' do
      subject { Post.search(filters: { status: %w[draft published] }) }

      it 'should generate a correct SQL query' do
        expect(subject.to_sql).to match(/WHERE(.*)"posts"."status" IN \('draft', 'published'\)/)
      end

      it 'should return the correct number of records' do
        expect(subject.count).to eq(Post.where(status: %w[draft published]).count)
      end
    end

    describe 'order posts' do
      let(:order_fields) { %w[title id] }
      subject { Post.search(order: order_fields) }

      it 'should generate a correct SQL query' do
        order_str = order_fields.map { |field| %("posts"."#{field}" ASC) }.join(', ')

        expect(subject.to_sql).to match(/ORDER BY(.*)#{order_str}/)
      end

      context 'when speficying a custom order' do
        let(:order_fields) { [{ field: 'title', asc: false }, 'id'] }

        it 'should generate a correct SQL query' do
          order_str = order_fields.map do |field|
            field_name = field.is_a?(Hash) ? field[:field] : field
            order_dir = field.is_a?(Hash) && field[:asc] == false ? 'DESC' : 'ASC'

            %("posts"."#{field_name}" #{order_dir})
          end.join(', ')

          expect(subject.to_sql).to match(/ORDER BY(.*)#{order_str}/)
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
