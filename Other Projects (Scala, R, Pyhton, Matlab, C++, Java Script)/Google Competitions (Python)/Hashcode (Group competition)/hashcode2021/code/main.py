from multiprocessing import Pool
import numpy as np
from dataclasses import dataclass
from typing import List
from hashcode.hilfsfunktionen import find_ampel_zeiten


@dataclass
class Setting:
    duration: int  # D
    num_intersections: int  # I ==> ID-1
    num_streets: int  # S
    num_cars: int  # V
    bonus: int  # D


@dataclass
class Intersection:
    id: int
    incoming: List[str]
    outgoing: List[str]


@dataclass
class Street:
    start: int  # B start intersection
    end: int  # E end intersection
    name: str
    travel_time: int  # L time it takes to travel
    befahrungen: int = 0


@dataclass
class Path:
    num_streets: int  # P
    street_names: List[str]


@dataclass
class Streetlight:
    name: str
    duration: int

    def __str__(self):
        return f"{self.name} {self.duration}"


@dataclass
class Schedule:
    id: int  # ID of intersection
    num_incoming_streets: int
    streetlights: List[Streetlight]

    def __str__(self):
        n = "\n"
        return f"{self.id}{n}{self.num_incoming_streets}{n}{n.join([str(light) for light in self.streetlights])}"


@dataclass
class Output:
    A: int  # number of intersections
    schedules: List[Schedule]

    def __str__(self):
        n = "\n"
        return f"{self.A}{n}{n.join([str(schedule) for schedule in self.schedules])}"


def read_file(filename):
    data: dict = {"setting": None, "streets": {}, "paths": [], "intersections": {}}
    with open("data/" + filename) as file:
        for index, line in enumerate(file):
            line_as_list = line.rstrip().split(" ")
            if index == 0:  # First line
                data["setting"] = Setting(
                    duration=int(line_as_list[0]),
                    num_intersections=int(line_as_list[1]),
                    num_streets=int(line_as_list[2]),
                    num_cars=int(line_as_list[3]),
                    bonus=int(line_as_list[4]),
                )
            elif index != 0 and index <= data["setting"].num_streets:  # S
                start = int(line_as_list[0])
                end = int(line_as_list[1])
                name = line_as_list[2]
                data["streets"][name] = Street(
                    start=start,
                    end=end,
                    name=name,
                    travel_time=int(line_as_list[3]),
                )

                if end not in data["intersections"]:
                    data["intersections"][end] = Intersection(
                        id=start, incoming=[name], outgoing=[]
                    )
                else:
                    data["intersections"][end].incoming.append(name)
                if start not in data["intersections"]:
                    data["intersections"][start] = Intersection(
                        id=start, incoming=[], outgoing=[name]
                    )
                else:
                    data["intersections"][start].outgoing.append(name)
            else:
                street_names = line_as_list[1:]
                timer = 0
                for street in street_names:
                    street = data["streets"][street]
                    timer = timer + street.travel_time
                    if timer < data["setting"].duration:
                        street.befahrungen += 1
                data["paths"].append(
                    Path(
                        num_streets=int(line_as_list[0]),
                        street_names=street_names,
                    )
                )
    return data


def write_file(result, filename):
    with open("result/" + filename, "w") as file:
        file.write(str(result))


def solve(data):
    solution = Output(A=0, schedules=[])
    for id, inter in data["intersections"].items():
        helperArray = np.zeros(len(inter.incoming)).astype(int)
        solution.A += 1
        new = Schedule(id=id, num_incoming_streets=0, streetlights=[])
        for index, street in enumerate(inter.incoming):
            helperArray[index] = data["streets"][street].befahrungen
        gruene_zeiten = find_ampel_zeiten(
            helperArray, data["setting"].duration, "quadratic"
        )
        for index, street in enumerate(inter.incoming):
            new.num_incoming_streets += 1
            new.streetlights.append(
                Streetlight(name=street, duration=gruene_zeiten[index])
            )
        solution.schedules.append(new)
    return solution


def main():
    files = ["a.txt", "b.txt", "c.txt", "d.txt", "e.txt", "f.txt"]
    for filename in files:
        data = read_file(filename)
        solution = solve(data)
        write_file(solution, filename)


# def f(x):
#     return x*x

# if __name__ == '__main__':
#     with Pool() as p:
#         print(p.map(f, [1, 2, 3]))