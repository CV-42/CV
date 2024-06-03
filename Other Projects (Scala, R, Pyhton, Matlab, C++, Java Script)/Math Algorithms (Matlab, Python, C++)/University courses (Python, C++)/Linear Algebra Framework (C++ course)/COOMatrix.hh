#pragma once

#include <map>
#include <ostream>
#include <vector>

namespace scprog {
    // forward declaration
    class Vector;

    class DenseMatrix;

    class COOMatrix {
    public:
        using value_type = double;
        using size_type = std::size_t;

        //constructs 0-matrix with dimensions rows x cols
        COOMatrix(size_type rows, size_type cols)
            : rows_(rows), cols_(cols)
            {};

        // const access to  element (i,j) allowed
        value_type const access(size_type const i, const size_type j) const;

        // We need a setter method, because it can check, if the value is zero.
        // If it is zero --> delete entry
        // (mutable access method cannot control this)
        void set(value_type a, size_type const i, size_type const j);

        //number of rows
        size_type rows() const { return rows_; }

        //number of columns
        size_type cols() const { return cols_; }

        //matrix-vector multiplication, checking dimensions
        void mat_vec(Vector const& x, Vector& y);

        // print the matrix
        friend std::ostream& operator<<(std::ostream& os, COOMatrix const& M);

    private:
        size_type rows_;
        size_type cols_;
        std::map< std::pair<size_type, size_type>, value_type > map_;
    };


} // end namespace scprog
