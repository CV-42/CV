#include <ostream>

#include "COOMatrix.hh"
#include "Vector.hh"

namespace scprog {

    using value_type = COOMatrix::value_type;
    using size_type = COOMatrix::size_type;

    template<class T>
    bool floatEquals(T const& a, T const& b, T eps = 1e-12)
    {
        return (std::abs(a - b) / std::abs(a + b) < eps);
    }

    void COOMatrix::set(value_type a, size_type const i, size_type const j) {
        // reference to entry of index (i,j), if it exists:
        auto search = this->map_.find(std::pair(i,j));

        // If no entry exitsts, and a != 0: create entry with a:
        if (search == map_.end() && !floatEquals(a, 0.))
            map_.insert({std::pair(i,j), a});

        // If entry exists, and a == 0: delete the entry:
        if (search != map_.end() && floatEquals(a, 0.))
            map_.erase(std::pair(i,j));

        if (search != map_.end() && !floatEquals(a, 0.))
            search->second = a;
    }

    value_type const COOMatrix::access(size_type const i, size_type const j) const {
        // reference to entry (i,j), if it exists:
        auto search = map_.find(std::pair(i,j));

        // if entry (i,j) exists, return value, else only return 0:
        if ( search != map_.end())
            return search->second;
        else
            return 0;
    }

    void COOMatrix::mat_vec(Vector const &x, Vector &y) {
        if (cols() != x.size())
            throw std::invalid_argument(
                    "Invalid size! Size of the Vector x must be equal to number of columns of the Matrix mat.");
        if (rows() != y.size())
            throw std::invalid_argument(
                    "Invalid size! Size of the result Vector y must be equal to number of rows of the Matrix mat.");

        // initialize to zero-vector:
        for (std::size_t i = 0; i < y.size(); ++i){
            y.access(i) = 0;
        }
        // y[i] +=  map[i,j] * x[j], for all entries (i,j) existing in map_,
        for (auto const [key, value]: map_) {
            y.access(key.first) += value * x.access(key.second);
        }
    }

    std::ostream& operator<<(std::ostream& os, COOMatrix const& M) {
        for (auto const& [key, value]: M.map_) {
            os << "(" << key.first << "," << key.second << "): " << value << std::endl;
        }
        return os;
    }
}

