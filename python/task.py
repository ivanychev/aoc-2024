import enum
import itertools
from dataclasses import dataclass, field
from functools import cache
from types import MappingProxyType
from typing import Self, Mapping
from collections import Counter
from more_itertools import windowed

INPUT = """
208A
540A
685A
879A
826A
"""

CODES = tuple(l for l in INPUT.split('\n') if l)

def str_path_to_counter(path: str) -> Counter:
    return Counter(windowed(path, 2))

@dataclass(frozen=True)
class Path:
    steps: list[tuple['Delta', int]]

    def __str__(self) -> str:
        return ''.join(step.char() * distance for step, distance in self.steps)

    def with_suffix(self, suffix: list[tuple['Delta', int]]) -> Self:
        return Path(self.steps + suffix)


@dataclass(frozen=True)
class Delta:
    dx: int
    dy: int

    def char(self) -> str:
        assert abs(self.dx) + abs(self.dy) <= 1
        if self.dx == 1:
            return '>'
        if self.dx == -1:
            return '<'
        if self.dy == 1:
            return 'v'
        if self.dy == -1:
            return '^'
        if self.dx == self.dy == 0:
            return 'A'
        raise ValueError(f"Invalid delta: {self}")

    @classmethod
    def up(cls):
        return cls(0, -1)

    @classmethod
    def down(cls):
        return cls(0, 1)

    @classmethod
    def left(cls):
        return cls(-1, 0)

    @classmethod
    def right(cls):
        return cls(1, 0)

    def straight_paths(self) -> list[Path]:
        steps = []
        if self.dx:
            steps.append((Delta(self.dx // abs(self.dx), 0), abs(self.dx)))
        if self.dy:
            steps.append((Delta(0, self.dy // abs(self.dy)), abs(self.dy)))
        result = [steps]
        if len(steps) == 2:
            result.append(steps[::-1])
        return [Path(r) for r in result]

@dataclass(frozen=True)
class Point:
    x: int
    y: int

    def step(self, d: Delta) -> Self:
        return Point(self.x + d.dx, self.y + d.dy)

def any_path(paths: list[Path]):
    return paths[0]

@dataclass(frozen=True)
class Pad:
    code_map: Mapping[str, Point] = field(hash=False)
    forbidden_points: frozenset[Point]
    start: Point

    @cache
    def get_paths(self, from_: str, to: str) -> list[Path]:
        from_point = self.code_map[from_]
        to_point = self.code_map[to]
        delta = Delta(to_point.x - from_point.x, to_point.y - from_point.y)
        paths = delta.straight_paths()
        return [p for p in paths if self._valid_path(from_point, p.steps)]

    def _valid_path(self, from_point: Point, path: list[tuple[Delta, int]]) -> bool:
        for step, distance in path:
            for i in range(distance):
                from_point = from_point.step(step)
                if from_point in self.forbidden_points:
                    return False
        return True



# +---+---+---+
# | 7 | 8 | 9 |
# +---+---+---+
# | 4 | 5 | 6 |
# +---+---+---+
# | 1 | 2 | 3 |
# +---+---+---+
#     | 0 | A |
#     +---+---+
NUM_PAD = Pad(
    code_map=MappingProxyType({
        '1': Point(0, 2),
        '2': Point(1, 2),
        '3': Point(2, 2),
        '4': Point(0, 1),
        '5': Point(1, 1),
        '6': Point(2, 1),
        '7': Point(0, 0),
        '8': Point(1, 0),
        '9': Point(2, 0),
        '0': Point(1, 3),
        'A': Point(2, 3),
    }),
    forbidden_points=frozenset([Point(0, 3)]),
    start=Point(2, 3),
)

# < cost

# +---+---+---+
# |   | ^ | A | # двинуть влево
# +---+---+---+
# | < | v | > |
# +---+---+---+

# +---+---+---+
# |   | ^ | A | # нажать на лево
# +---+---+---+
# | < | v | > |
# +---+---+---+

# +---+---+---+
# |   | ^ | A | # увести курсор до кнопки лево и нажать A
# +---+---+---+
# | < | v | > |
# +---+---+---+

# +---+---+---+
# |   | ^ | A | # путешествие до кнопки лево, А, потом путешествие до кнопки А, А
# +---+---+---+
# | < | v | > |
# +---+---+---+

# V<A

ARROW_PAD = Pad(
    code_map=MappingProxyType({
        'v': Point(1, 1),
        '^': Point(1, 0),
        'A': Point(2, 0),
        '<': Point(0, 1),
        '>': Point(2, 1),
    }),
    forbidden_points=frozenset([Point(0, 0)]),
    start=Point(2, 0),
)

PRESS_DIAL_COMPONENT = [Path([(Delta(0, 0), 1)])]

def get_shortest_dial_for_path(path: str, intermediates: int) -> str:
    dial_components = []

    for pair in windowed(itertools.chain('A', path), 2):
        dial_components.append(NUM_PAD.get_paths(*pair))
        dial_components.append(PRESS_DIAL_COMPONENT)

    arrow_dials = set()
    for dial_variant in itertools.product(*dial_components):
        arrow_dials.add(''.join(str(p) for p in dial_variant))

    for _ in range(intermediates):
        updated_arrow_dials = set()
        for dial in arrow_dials:
            dial_components = []
            for pair in windowed(itertools.chain('A', dial), 2):
                dial_components.append(ARROW_PAD.get_paths(*pair))
                dial_components.append(PRESS_DIAL_COMPONENT)
            for dial_variant in itertools.product(*dial_components):
                value = ''.join(str(p) for p in dial_variant)
                # if value == 'v<A<AA>>^AvA<^A>AvA^Av<A<A>>^A<A>vA^Av<<A>>^AAAvA^Av<<A>A>^AAAvA^A<A>A':
                #     pass
                updated_arrow_dials.add(value)
        arrow_dials = updated_arrow_dials
    return sorted(arrow_dials, key=len)[0]

ARROW_ALL = 'v<>^A'

def total_moves(c: Counter):
    return sum(len(k) * v for k, v in c.items())

def explode_atoms(atoms: Counter) -> Counter:
    new_counter = Counter()
    for atom, count in atoms.items():
        new_counter +=  Counter({k: count * v for k, v in atom_to_exploded_atoms(atom).items()})
    return new_counter

# Atom is ...A action

@cache
def path_to_atoms(path: str) -> Counter[str]:
    assert path.endswith('A')
    a_indices = [-1]
    start = 0
    while start != -1:
        start = path.find('A', start)
        if start != -1:
            a_indices.append(start)
            start += 1
    return Counter(path[i+1:j+1] for i, j in windowed(a_indices, 2))

@cache
def atom_to_exploded_atoms(atom: str) -> Counter[str]:
    # atom can be "v<A" — "v<A<A>>^A or "A" -> "A"
    root_path = Path([])
    for pair in windowed(itertools.chain('A', atom), 2):
        root_path = root_path.with_suffix(any_path(ARROW_PAD.get_paths(*pair)).steps)
        root_path = root_path.with_suffix([(Delta(0, 0), 1)])
    return Counter(path_to_atoms(str(root_path)))


def main():

    total = 0
    for path in CODES:
        shortest_dial = get_shortest_dial_for_path(path, 1)
        atom_counters = path_to_atoms(shortest_dial)
        # for _ in range(22):
        #     atom_counters = explode_atoms(atom_counters)
        # total += total_moves(exploded_counter) * int(path[:-1])

        # total += len(shortest_dial) * int(path[:-1])
        total += total_moves(atom_counters) * int(path[:-1])

    # 224326
    # not 326335714664662 — too high
    #     128338601787924 — too low

    print(f"{total=}")


if __name__ == "__main__":
    main()
