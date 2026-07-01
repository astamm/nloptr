#include <ostream>

class NullOStream : public std::ostream {
public:
    NullOStream() : std::ostream(nullptr) {}
};

NullOStream null_ostream;
