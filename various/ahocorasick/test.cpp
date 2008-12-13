#include "ahocorasick.hpp"

#include <cstdio>

#include <fstream>
#include <iostream>
#include <string>
#include <vector>

#include <boost/assign/list_of.hpp>

using namespace std;
using namespace boost::assign;

template <typename KeywordStoreT>
struct Results
{
	Results(KeywordStoreT const & keywords)
	:	keywords_(keywords),
		hits_(keywords.size())
	{
	}

	void operator()(size_t what, size_t where)
	{
		cout << "[" << where << "]" << keywords_[what] << endl;
		hits_[what].insert(where);
	}

	KeywordStoreT const &keywords_;
	vector<set<size_t> > hits_;
};

typedef vector<set<size_t> > (*test_function_t)(vector<string> const &, char const *, char const *);

vector<set<size_t> >
matt_test_function(vector<string> const & keywords, char const *begin, char const *end)
{
	AhoCorasick<char> ac(keywords.begin(), keywords.end());
	Results <vector<string> > results(keywords);
	ac.search(begin, end, results);
	return results.hits_;
}

static vector<test_function_t> test_functions = list_of(matt_test_function);

int main()
{
	vector<string> const keywords = list_of("he")("she")("his")("hers");
	char const input[] = "ushers";
	vector<set<size_t> > const expected = list_of<set<size_t> >
			(list_of(3))
			(list_of(3))
			()
			(list_of(5));

	for (vector<test_function_t>::iterator it = test_functions.begin();
		it != test_functions.end(); ++it)
	{
		assert(expected == (**it)(keywords, &input[0], &input[sizeof(input)]));
	}

	{
		vector<string> const file_kw = list_of("sex")("dick")("c++");
		AhoCorasick<char> matt_ac(file_kw.begin(), file_kw.end());
		Results<vector<string> > results(file_kw);
		ifstream fag("input", ifstream::binary);
		while (fag.good()) {
#if 1
			char buf[512];
			fag.read(buf, 512);
			matt_ac.search(buf, buf + fag.gcount(), results);
#else
			char c = fag.get();
			matt_ac.search(&c, &c + 1, results);
#endif
		}
	}

	return 0;
}
